import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'app_database.steps.dart';
import 'migrations/v6_mood_emojis.dart';
import 'search_index.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// Local SQLite database. It is the single source of truth for notes.
///
/// Schema history (dumps in `drift_schemas/`, tested in
/// `test/core/database/migration_test.dart`):
/// * v1: notes, tags, note_tags
/// * v2: notes_fts full-text index (FTS5), back-filled on upgrade
/// * v3: tags get an emoji instead of a colour
/// * v4: optional place name (also indexed)
/// * v5: place coordinates (world map), collections
/// * v6: optional title (also indexed), photo aspect ratio; Stimmungen that
///   still had the v3 default emoji get a fitting one
/// * v7: country (code) and the place's English name, both indexed with the
///   country names table; the v5 place coordinates are dropped – only names
///   are stored
/// * v8: optional song (Spotify URI, title, artist, stored cover); title and
///   artist are indexed
/// * v9: collections get a position (their order in the overview, changed
///   by dragging); existing ones keep their order (newest first)
/// * v10: notes and collections get a random `uid` – their identity in a
///   backup, independent of row ids and device-specific asset ids
///
/// To change the schema: bump [schemaVersion], run
/// `dart run drift_dev make-migrations`, add the `fromXToY` step below and
/// extend the migration test. Never edit an existing step.
@DriftDatabase(
  tables: [Notes, Tags, NoteTags, Collections, CollectionNotes, Countries],
  include: {'search.drift'},
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Opens the on-device database in the app's private documents directory.
  factory AppDatabase.open() => AppDatabase(driftDatabase(name: 'randnotiz'));

  @override
  int get schemaVersion => 10;

  late final SearchIndex searchIndex = SearchIndex(this);

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        await m.create(schema.notesFts);
        // Frozen v2 SQL: migrations must not depend on today's index code.
        await customStatement('''
INSERT INTO notes_fts(rowid, body, tags)
SELECT n.id, n.body,
  COALESCE((SELECT group_concat(t.name, ' · ')
            FROM note_tags nt JOIN tags t ON t.id = nt.tag_id
            WHERE nt.note_id = n.id), '')
FROM notes n''');
      },
      from2To3: (m, schema) async {
        // Rebuilds the tags table: drops "color", adds "emoji" with its
        // default. Runs before foreign keys are switched on in beforeOpen,
        // so the note_tags rows are left untouched.
        await m.alterTable(
          TableMigration(schema.tags, newColumns: [schema.tags.emoji]),
        );
      },
      from3To4: (m, schema) async {
        await m.addColumn(schema.notes, schema.notes.placeName);
        // FTS5 tables cannot get new columns: recreate and refill.
        await m.deleteTable('notes_fts');
        await m.create(schema.notesFts);
        // Frozen v4 SQL (see from1To2).
        await customStatement('''
INSERT INTO notes_fts(rowid, body, tags, place)
SELECT n.id, n.body,
  COALESCE((SELECT group_concat(t.name, ' · ')
            FROM note_tags nt JOIN tags t ON t.id = nt.tag_id
            WHERE nt.note_id = n.id), ''),
  COALESCE(n.place_name, '')
FROM notes n''');
      },
      from4To5: (m, schema) async {
        await m.addColumn(schema.notes, schema.notes.placeLatitude);
        await m.addColumn(schema.notes, schema.notes.placeLongitude);
        await m.create(schema.collections);
        await m.create(schema.collectionNotes);
      },
      from5To6: (m, schema) async {
        await m.addColumn(schema.notes, schema.notes.title);
        await m.addColumn(schema.notes, schema.notes.photoAspect);
        // FTS5 tables cannot get new columns: recreate and refill.
        await m.deleteTable('notes_fts');
        await m.create(schema.notesFts);
        // Frozen v6 SQL (see from1To2).
        await customStatement('''
INSERT INTO notes_fts(rowid, body, tags, place, title)
SELECT n.id, n.body,
  COALESCE((SELECT group_concat(t.name, ' · ')
            FROM note_tags nt JOIN tags t ON t.id = nt.tag_id
            WHERE nt.note_id = n.id), ''),
  COALESCE(n.place_name, ''),
  COALESCE(n.title, '')
FROM notes n''');
        // Stimmungen still carrying the v3 default emoji get one that fits
        // their name (frozen table). Emojis the user chose stay.
        final defaults = await customSelect(
          'SELECT id, name FROM tags WHERE emoji = ?',
          variables: [Variable.withString(v6DefaultEmoji)],
        ).get();
        for (final row in defaults) {
          final emoji = v6EmojiForMoodName(row.read<String>('name'));
          if (emoji == null) continue;
          await customStatement('UPDATE tags SET emoji = ? WHERE id = ?', [
            emoji,
            row.read<int>('id'),
          ]);
        }
      },
      from6To7: (m, schema) async {
        // Rebuilds the notes table: adds country, the place's second name
        // and the back-fill flag, drops the place coordinates of v5.
        // Runs before foreign keys are switched on (see from2To3).
        await m.alterTable(
          TableMigration(
            schema.notes,
            newColumns: [
              schema.notes.placeNameAlt,
              schema.notes.countryCode,
              schema.notes.geoChecked,
            ],
          ),
        );
        await m.create(schema.countries);
        await m.deleteTable('notes_fts');
        await m.create(schema.notesFts);
        // Frozen v7 SQL. The countries table is filled at start-up, which
        // re-indexes the notes then (CountryNamesSync).
        await customStatement('''
INSERT INTO notes_fts(rowid, body, tags, place, title, country)
SELECT n.id, n.body,
  COALESCE((SELECT group_concat(t.name, ' · ')
            FROM note_tags nt JOIN tags t ON t.id = nt.tag_id
            WHERE nt.note_id = n.id), ''),
  TRIM(COALESCE(n.place_name, '') || ' ' || COALESCE(n.place_name_alt, '')),
  COALESCE(n.title, ''),
  ''
FROM notes n''');
      },
      from7To8: (m, schema) async {
        await m.addColumn(schema.notes, schema.notes.songUri);
        await m.addColumn(schema.notes, schema.notes.songTitle);
        await m.addColumn(schema.notes, schema.notes.songArtist);
        await m.addColumn(schema.notes, schema.notes.songCoverFile);
        // FTS5 tables cannot get new columns: recreate and refill.
        await m.deleteTable('notes_fts');
        await m.create(schema.notesFts);
        // Frozen v8 SQL (see from1To2). No note has a song yet.
        await customStatement('''
INSERT INTO notes_fts(rowid, body, tags, place, title, country, song)
SELECT n.id, n.body,
  COALESCE((SELECT group_concat(t.name, ' · ')
            FROM note_tags nt JOIN tags t ON t.id = nt.tag_id
            WHERE nt.note_id = n.id), ''),
  TRIM(COALESCE(n.place_name, '') || ' ' || COALESCE(n.place_name_alt, '')),
  COALESCE(n.title, ''),
  COALESCE((SELECT c.name_de || ' ' || c.name_en
            FROM countries c WHERE c.code = n.country_code), ''),
  ''
FROM notes n''');
      },
      from8To9: (m, schema) async {
        await m.addColumn(schema.collections, schema.collections.position);
        // Frozen v9 SQL: numbers the collections in their former order
        // (newest first), so the overview looks the same after the update.
        await customStatement(
          '''
UPDATE collections SET position = (
  SELECT COUNT(*) FROM collections c2
  WHERE c2.created_at > collections.created_at
     OR (c2.created_at = collections.created_at AND c2.id > collections.id))''',
        );
      },
      from9To10: (m, schema) async {
        // Rebuilds both tables (SQLite cannot add a UNIQUE NOT NULL column)
        // and gives every existing row a random uid. Frozen SQL; runs
        // before foreign keys are switched on (see from2To3), row ids stay.
        const uid = CustomExpression<String>('lower(hex(randomblob(16)))');
        await m.alterTable(
          TableMigration(
            schema.notes,
            columnTransformer: {schema.notes.uid: uid},
            newColumns: [schema.notes.uid],
          ),
        );
        await m.alterTable(
          TableMigration(
            schema.collections,
            columnTransformer: {schema.collections.uid: uid},
            newColumns: [schema.collections.uid],
          ),
        );
      },
    ),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
