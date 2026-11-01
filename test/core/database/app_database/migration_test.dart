// Tests the schema migrations against the schema dumps in drift_schemas/.
// Regenerate the helpers with `dart run drift_dev make-migrations`.
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/core/database/app_database.dart';
import 'package:randnotiz/features/geo/data/country_names_sync.dart';
import 'package:randnotiz/features/geo/domain/geo.dart';
import 'package:randnotiz/features/music/domain/song.dart';
import 'package:randnotiz/features/notes/data/drift_note_repository.dart';
import 'package:randnotiz/features/notes/domain/note.dart';
import 'package:randnotiz/features/weather/domain/weather.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v10.dart' as v10;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;
import 'generated/schema_v4.dart' as v4;
import 'generated/schema_v5.dart' as v5;
import 'generated/schema_v6.dart' as v6;
import 'generated/schema_v7.dart' as v7;
import 'generated/schema_v8.dart' as v8;
import 'generated/schema_v9.dart' as v9;

/// Old schema snapshots store dates as raw unix seconds.
int _secs(DateTime d) => d.millisecondsSinceEpoch ~/ 1000;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('every upgrade path produces the expected schema', () {
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  test('fresh install matches the latest schema dump', () async {
    final schema = await verifier.schemaAt(GeneratedHelper.versions.last);
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, GeneratedHelper.versions.last);
    await db.close();
  });

  test('v1 → v2 keeps all user data and back-fills the search index', () async {
    final created = _secs(DateTime(2024, 3, 1));
    final oldNotes = [
      v1.NotesData(
        id: 1,
        assetId: '1001',
        body: 'Picknick mit Oma im Grünen',
        noteDate: _secs(DateTime(2023, 6, 18, 15)),
        weatherKind: 'clear',
        temperatureC: 24.0,
        thumbnailFile: 'n1.jpg',
        createdAt: created,
        updatedAt: created,
      ),
      v1.NotesData(
        id: 2,
        assetId: '1002',
        body: 'Regentag',
        noteDate: _secs(DateTime(2022, 11, 2, 9)),
        createdAt: created,
        updatedAt: created,
      ),
    ];
    const oldTags = [v1.TagsData(id: 1, name: 'Familie', color: 0xFFC0583A)];
    const oldLinks = [v1.NoteTagsData(noteId: 1, tagId: 1)];

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.notes, oldNotes);
        batch.insertAll(oldDb.tags, oldTags);
        batch.insertAll(oldDb.noteTags, oldLinks);
      },
      validateItems: (newDb) async {
        expect(await newDb.select(newDb.notes).get(), [
          for (final n in oldNotes)
            v2.NotesData(
              id: n.id,
              assetId: n.assetId,
              body: n.body,
              noteDate: n.noteDate,
              weatherKind: n.weatherKind,
              temperatureC: n.temperatureC,
              thumbnailFile: n.thumbnailFile,
              createdAt: n.createdAt,
              updatedAt: n.updatedAt,
            ),
        ]);
        expect(await newDb.select(newDb.tags).get(), [
          const v2.TagsData(id: 1, name: 'Familie', color: 0xFFC0583A),
        ]);
        expect(await newDb.select(newDb.noteTags).get(), [
          const v2.NoteTagsData(noteId: 1, tagId: 1),
        ]);
      },
    );
  });

  test('after upgrading, old notes are found by text and tag name', () async {
    final schema = await verifier.schemaAt(1);
    final oldDb = v1.DatabaseAtV1(schema.newConnection());
    final when = _secs(DateTime(2024));
    await oldDb
        .into(oldDb.notes)
        .insert(
          v1.NotesCompanion.insert(
            assetId: '5',
            noteDate: when,
            createdAt: when,
            updatedAt: when,
            body: const Value('Erster Schultag'),
          ),
        );
    await oldDb
        .into(oldDb.tags)
        .insert(v1.TagsCompanion.insert(name: 'Schule', color: 1));
    await oldDb
        .into(oldDb.noteTags)
        .insert(v1.NoteTagsCompanion.insert(noteId: 1, tagId: 1));
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    final repo = DriftNoteRepository(db);
    final byText = await repo
        .watchJournal(const JournalQuery(text: 'schult'))
        .first;
    final byTag = await repo
        .watchJournal(const JournalQuery(text: 'schule'))
        .first;
    expect(byText.single.assetId, '5');
    expect(byTag.single.tags.single.name, 'Schule');
    await db.close();
  });

  test('v2 → v3 turns tags into Stimmungen without losing links', () async {
    final when = _secs(DateTime(2025, 6, 1));
    await verifier.testWithDataIntegrity(
      oldVersion: 2,
      newVersion: 3,
      createOld: v2.DatabaseAtV2.new,
      createNew: v3.DatabaseAtV3.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insert(
          oldDb.notes,
          v2.NotesCompanion.insert(
            assetId: '9',
            noteDate: when,
            createdAt: when,
            updatedAt: when,
            body: const Value('Sonntag am See'),
          ),
        );
        batch.insertAll(oldDb.tags, const [
          v2.TagsData(id: 1, name: 'Ausflug', color: 0xFF4F7C6B),
          v2.TagsData(id: 2, name: 'Familie', color: 0xFFC0583A),
        ]);
        batch.insertAll(oldDb.noteTags, const [
          v2.NoteTagsData(noteId: 1, tagId: 1),
          v2.NoteTagsData(noteId: 1, tagId: 2),
        ]);
      },
      validateItems: (newDb) async {
        expect(await newDb.select(newDb.tags).get(), const [
          v3.TagsData(id: 1, name: 'Ausflug', emoji: '🙂'),
          v3.TagsData(id: 2, name: 'Familie', emoji: '🙂'),
        ]);
        expect(await newDb.select(newDb.noteTags).get(), const [
          v3.NoteTagsData(noteId: 1, tagId: 1),
          v3.NoteTagsData(noteId: 1, tagId: 2),
        ]);
        expect(
          (await newDb.select(newDb.notes).get()).single.body,
          'Sonntag am See',
        );
      },
    );
  });

  test('v3 → v4 adds the place and keeps notes searchable', () async {
    final when = _secs(DateTime(2025, 6, 1));
    await verifier.testWithDataIntegrity(
      oldVersion: 3,
      newVersion: 4,
      createOld: v3.DatabaseAtV3.new,
      createNew: v4.DatabaseAtV4.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insert(
          oldDb.notes,
          v3.NotesCompanion.insert(
            assetId: '3',
            noteDate: when,
            createdAt: when,
            updatedAt: when,
            body: const Value('Kirschblüten im Park'),
          ),
        );
      },
      validateItems: (newDb) async {
        final note = (await newDb.select(newDb.notes).get()).single;
        expect(note.body, 'Kirschblüten im Park');
        expect(note.placeName, isNull);
      },
    );

    // The rebuilt index still finds the old note.
    final schema = await verifier.schemaAt(3);
    final oldDb = v3.DatabaseAtV3(schema.newConnection());
    await oldDb
        .into(oldDb.notes)
        .insert(
          v3.NotesCompanion.insert(
            assetId: '3',
            noteDate: when,
            createdAt: when,
            updatedAt: when,
            body: const Value('Kirschblüten im Park'),
          ),
        );
    await oldDb.customStatement(
      "INSERT INTO notes_fts(rowid, body, tags) VALUES (1, 'Kirschblüten im Park', '')",
    );
    await oldDb.close();
    final db = AppDatabase(schema.newConnection());
    final hits = await DriftNoteRepository(db)
        .watchJournal(const JournalQuery(text: 'kirsch'))
        .first;
    expect(hits.single.assetId, '3');
    await db.close();
  });

  test('v4 → v5 keeps notes and places, collections start empty', () async {
    final when = _secs(DateTime(2025, 8, 3));
    await verifier.testWithDataIntegrity(
      oldVersion: 4,
      newVersion: 5,
      createOld: v4.DatabaseAtV4.new,
      createNew: v5.DatabaseAtV5.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insert(
          oldDb.notes,
          v4.NotesCompanion.insert(
            assetId: '5',
            noteDate: when,
            createdAt: when,
            updatedAt: when,
            body: const Value('Fischbrötchen am Hafen'),
            placeName: const Value('Hamburg'),
          ),
        );
      },
      validateItems: (newDb) async {
        final note = (await newDb.select(newDb.notes).get()).single;
        expect(note.body, 'Fischbrötchen am Hafen');
        expect(note.placeName, 'Hamburg');
        // Coordinates are back-filled later (by the map), not invented here.
        expect(note.placeLatitude, isNull);
        expect(note.placeLongitude, isNull);
        expect(await newDb.select(newDb.collections).get(), isEmpty);
      },
    );
  });

  test(
    'v5 → v6 keeps everything, adds the title and fits mood emojis',
    () async {
      final when = _secs(DateTime(2025, 9, 14));
      await verifier.testWithDataIntegrity(
        oldVersion: 5,
        newVersion: 6,
        createOld: v5.DatabaseAtV5.new,
        createNew: v6.DatabaseAtV6.new,
        openTestedDatabase: AppDatabase.new,
        createItems: (batch, oldDb) {
          batch.insert(
            oldDb.notes,
            v5.NotesCompanion.insert(
              assetId: '11',
              noteDate: when,
              createdAt: when,
              updatedAt: when,
              body: const Value('Monstera umgetopft'),
              placeName: const Value('Leipzig'),
              placeLatitude: const Value(51.34),
              placeLongitude: const Value(12.37),
              thumbnailFile: const Value('note_11.jpg'),
            ),
          );
          batch.insertAll(oldDb.tags, const [
            // v3 default emoji + a name that has a fitting emoji
            v5.TagsData(id: 1, name: 'Pflanzen', emoji: '🙂'),
            // chosen by the user: stays
            v5.TagsData(id: 2, name: 'Melancholie', emoji: '🌿'),
            // default emoji, nothing fits: stays
            v5.TagsData(id: 3, name: 'Xyz', emoji: '🙂'),
          ]);
          batch.insertAll(oldDb.noteTags, const [
            v5.NoteTagsData(noteId: 1, tagId: 1),
            v5.NoteTagsData(noteId: 1, tagId: 2),
          ]);
          batch.insert(
            oldDb.collections,
            v5.CollectionsCompanion.insert(name: 'Balkon', createdAt: when),
          );
          batch.insert(
            oldDb.collectionNotes,
            v5.CollectionNotesCompanion.insert(
              collectionId: 1,
              noteId: 1,
              addedAt: when,
            ),
          );
        },
        validateItems: (newDb) async {
          final note = (await newDb.select(newDb.notes).get()).single;
          expect(note.body, 'Monstera umgetopft');
          expect(note.placeName, 'Leipzig');
          expect(note.placeLatitude, 51.34);
          expect(note.thumbnailFile, 'note_11.jpg');
          expect(note.title, isNull);
          expect(note.photoAspect, isNull);
          expect(await newDb.select(newDb.tags).get(), const [
            v6.TagsData(id: 1, name: 'Pflanzen', emoji: '🌱'),
            v6.TagsData(id: 2, name: 'Melancholie', emoji: '🌿'),
            v6.TagsData(id: 3, name: 'Xyz', emoji: '🙂'),
          ]);
          expect(await newDb.select(newDb.noteTags).get(), hasLength(2));
          expect(await newDb.select(newDb.collectionNotes).get(), hasLength(1));
        },
      );
    },
  );

  test('after v5 → v6 old notes are still found, titles too', () async {
    final schema = await verifier.schemaAt(5);
    final oldDb = v5.DatabaseAtV5(schema.newConnection());
    final when = _secs(DateTime(2025, 9, 14));
    await oldDb
        .into(oldDb.notes)
        .insert(
          v5.NotesCompanion.insert(
            assetId: '12',
            noteDate: when,
            createdAt: when,
            updatedAt: when,
            body: const Value('Kraniche über dem Feld'),
            placeName: const Value('Linum'),
          ),
        );
    await oldDb.customStatement(
      'INSERT INTO notes_fts(rowid, body, tags, place) '
      "VALUES (1, 'Kraniche über dem Feld', '', 'Linum')",
    );
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    final repo = DriftNoteRepository(db);
    expect(
      (await repo.watchJournal(const JournalQuery(text: 'kranich')).first)
          .single
          .assetId,
      '12',
    );
    expect(
      (await repo.watchJournal(const JournalQuery(text: 'linum')).first),
      hasLength(1),
    );
    // Titles written after the upgrade are indexed.
    final note = (await repo.findByAsset('12'))!;
    await repo.save(
      NoteDraft(
        assetId: '12',
        body: note.body,
        date: note.date,
        title: 'Herbstzug',
        placeName: note.placeName,
      ),
    );
    final hits = await repo
        .watchJournal(const JournalQuery(text: 'herbstz'))
        .first;
    expect(hits.single.title, 'Herbstzug');
    await db.close();
  });

  test('v6 → v7 drops the coordinates, keeps everything else', () async {
    final when = _secs(DateTime(2025, 7, 20));
    await verifier.testWithDataIntegrity(
      oldVersion: 6,
      newVersion: 7,
      createOld: v6.DatabaseAtV6.new,
      createNew: v7.DatabaseAtV7.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insert(
          oldDb.notes,
          v6.NotesCompanion.insert(
            assetId: '21',
            noteDate: when,
            createdAt: when,
            updatedAt: when,
            body: const Value('Fähre nach Bergen'),
            title: const Value('Fjordtag'),
            placeName: const Value('Bergen'),
            placeLatitude: const Value(60.39),
            placeLongitude: const Value(5.32),
            photoAspect: const Value(0.75),
            weatherKind: const Value('rain'),
            temperatureC: const Value(14.5),
            thumbnailFile: const Value('note_21.jpg'),
          ),
        );
        batch.insert(
          oldDb.tags,
          v6.TagsCompanion.insert(name: 'Reise', emoji: const Value('✈️')),
        );
        batch.insert(
          oldDb.noteTags,
          v6.NoteTagsCompanion.insert(noteId: 1, tagId: 1),
        );
      },
      validateItems: (newDb) async {
        final note = (await newDb.select(newDb.notes).get()).single;
        expect(note.body, 'Fähre nach Bergen');
        expect(note.title, 'Fjordtag');
        expect(note.placeName, 'Bergen');
        expect(note.photoAspect, 0.75);
        expect(note.weatherKind, 'rain');
        expect(note.thumbnailFile, 'note_21.jpg');
        expect(note.countryCode, isNull, reason: 'filled by the back-fill');
        expect(note.geoChecked, 0, reason: 'stored as 0 = false');
        expect(await newDb.select(newDb.noteTags).get(), hasLength(1));
        expect(await newDb.select(newDb.countries).get(), isEmpty);
      },
    );
  });

  test('after v6 → v7 notes are found, then also by country', () async {
    final schema = await verifier.schemaAt(6);
    final oldDb = v6.DatabaseAtV6(schema.newConnection());
    final when = _secs(DateTime(2025, 7, 20));
    await oldDb
        .into(oldDb.notes)
        .insert(
          v6.NotesCompanion.insert(
            assetId: '22',
            noteDate: when,
            createdAt: when,
            updatedAt: when,
            body: const Value('Fähre nach Bergen'),
            placeName: const Value('Bergen'),
            placeLatitude: const Value(60.39),
            placeLongitude: const Value(5.32),
          ),
        );
    await oldDb.customStatement(
      'INSERT INTO notes_fts(rowid, body, tags, place, title) '
      "VALUES (1, 'Fähre nach Bergen', '', 'Bergen', '')",
    );
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    final repo = DriftNoteRepository(db);
    final columns = await db
        .customSelect('PRAGMA table_info(notes)')
        .map((r) => r.read<String>('name'))
        .get();
    expect(columns, isNot(contains('place_latitude')));
    expect(columns, isNot(contains('place_longitude')));
    expect(
      (await repo.watchJournal(const JournalQuery(text: 'fähre')).first),
      hasLength(1),
    );

    // The back-fill sets the country; the start-up sync names it.
    await repo.setGeo(1, countryCode: 'NO', placeName: 'Bergen');
    await CountryNamesSync(db).sync(const [
      Country(
        code: 'NO',
        nameDe: 'Norwegen',
        nameEn: 'Norway',
        isSmall: false,
        marker: GeoPoint(60, 8),
      ),
    ]);
    for (final q in ['norwegen', 'norway', 'bergen']) {
      expect(
        (await repo.watchJournal(JournalQuery(text: q)).first).single.assetId,
        '22',
        reason: q,
      );
    }
    await db.close();
  });

  test('v7 → v8 keeps notes, no song yet', () async {
    final when = _secs(DateTime(2025, 8, 1));
    await verifier.testWithDataIntegrity(
      oldVersion: 7,
      newVersion: 8,
      createOld: v7.DatabaseAtV7.new,
      createNew: v8.DatabaseAtV8.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insert(
          oldDb.notes,
          v7.NotesCompanion.insert(
            assetId: '31',
            noteDate: when,
            createdAt: when,
            updatedAt: when,
            body: const Value('Konzert im Park'),
            title: const Value('Sommerabend'),
            placeName: const Value('Hamburg'),
            countryCode: const Value('DE'),
            geoChecked: const Value(1),
          ),
        );
      },
      validateItems: (newDb) async {
        final note = (await newDb.select(newDb.notes).get()).single;
        expect(note.body, 'Konzert im Park');
        expect(note.title, 'Sommerabend');
        expect(note.countryCode, 'DE');
        expect(note.songUri, isNull);
        expect(note.songTitle, isNull);
      },
    );
  });

  test('after v7 → v8 notes are found, then also by their song', () async {
    final schema = await verifier.schemaAt(7);
    final oldDb = v7.DatabaseAtV7(schema.newConnection());
    final when = _secs(DateTime(2025, 8, 1));
    await oldDb
        .into(oldDb.notes)
        .insert(
          v7.NotesCompanion.insert(
            assetId: '32',
            noteDate: when,
            createdAt: when,
            updatedAt: when,
            body: const Value('Konzert im Park'),
          ),
        );
    await oldDb.customStatement(
      'INSERT INTO notes_fts(rowid, body, tags, place, title, country) '
      "VALUES (1, 'Konzert im Park', '', '', '', '')",
    );
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    final repo = DriftNoteRepository(db);
    expect(
      await repo.watchJournal(const JournalQuery(text: 'konzert')).first,
      hasLength(1),
    );
    await repo.save(
      NoteDraft(
        assetId: '32',
        body: 'Konzert im Park',
        date: DateTime(2025, 8, 1),
        song: const Song(
          uri: 'spotify:track:abc',
          title: 'Wonderwall',
          artist: 'Oasis',
        ),
      ),
    );
    for (final q in ['wonderwall', 'oasis', 'konzert']) {
      expect(
        (await repo.watchJournal(JournalQuery(text: q)).first).single.assetId,
        '32',
        reason: q,
      );
    }
    await db.close();
  });

  test('v8 → v9 keeps the order of the collections (newest first)', () async {
    final older = _secs(DateTime(2025, 1, 1));
    final newer = _secs(DateTime(2025, 6, 1));
    await verifier.testWithDataIntegrity(
      oldVersion: 8,
      newVersion: 9,
      createOld: v8.DatabaseAtV8.new,
      createNew: v9.DatabaseAtV9.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.collections, [
          v8.CollectionsCompanion.insert(name: 'Alt', createdAt: older),
          v8.CollectionsCompanion.insert(name: 'Neu', createdAt: newer),
          // Same time as "Neu", created later (higher id): before it.
          v8.CollectionsCompanion.insert(name: 'Neuer', createdAt: newer),
        ]);
      },
      validateItems: (newDb) async {
        final rows = await (newDb.select(
          newDb.collections,
        )..orderBy([(c) => OrderingTerm.asc(c.position)])).get();
        expect(rows.map((r) => r.name), ['Neuer', 'Neu', 'Alt']);
        expect(rows.map((r) => r.position), [0, 1, 2]);
      },
    );
  });

  test('v9 → v10 gives every note and collection its own uid', () async {
    final when = _secs(DateTime(2025, 9, 1));
    await verifier.testWithDataIntegrity(
      oldVersion: 9,
      newVersion: 10,
      createOld: v9.DatabaseAtV9.new,
      createNew: v10.DatabaseAtV10.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.notes, [
          for (final id in ['41', '42', 'picked:43'])
            v9.NotesCompanion.insert(
              assetId: id,
              noteDate: when,
              createdAt: when,
              updatedAt: when,
              body: Value('Notiz $id'),
              songTitle: const Value('Wonderwall'),
            ),
        ]);
        batch.insert(oldDb.tags, v9.TagsCompanion.insert(name: 'froh'));
        batch.insert(
          oldDb.noteTags,
          v9.NoteTagsCompanion.insert(noteId: 2, tagId: 1),
        );
        batch.insertAll(oldDb.collections, [
          v9.CollectionsCompanion.insert(name: 'Reise', createdAt: when),
          v9.CollectionsCompanion.insert(
            name: 'Sommer',
            createdAt: when,
            position: const Value(1),
          ),
        ]);
        batch.insert(
          oldDb.collectionNotes,
          v9.CollectionNotesCompanion.insert(
            collectionId: 2,
            noteId: 3,
            addedAt: when,
          ),
        );
      },
      validateItems: (newDb) async {
        final notes = await (newDb.select(
          newDb.notes,
        )..orderBy([(n) => OrderingTerm.asc(n.id)])).get();
        expect(notes.map((n) => (n.id, n.assetId, n.body)), [
          (1, '41', 'Notiz 41'),
          (2, '42', 'Notiz 42'),
          (3, 'picked:43', 'Notiz picked:43'),
        ]);
        expect(notes.first.songTitle, 'Wonderwall');
        final collections = await newDb.select(newDb.collections).get();
        expect(collections.map((c) => c.position), [0, 1]);
        final uids = [
          ...notes.map((n) => n.uid),
          ...collections.map((c) => c.uid),
        ];
        for (final uid in uids) {
          expect(uid, matches(RegExp(r'^[0-9a-f]{32}$')));
        }
        expect(uids.toSet(), hasLength(uids.length));
        expect((await newDb.select(newDb.noteTags).get()).single.noteId, 2);
        expect(
          (await newDb.select(newDb.collectionNotes).get()).single.noteId,
          3,
        );
      },
    );
  });

  test('after v9 → v10 notes are still found and new ones get a uid', () async {
    final schema = await verifier.schemaAt(9);
    final oldDb = v9.DatabaseAtV9(schema.newConnection());
    final when = _secs(DateTime(2025, 9, 1));
    await oldDb
        .into(oldDb.notes)
        .insert(
          v9.NotesCompanion.insert(
            assetId: '51',
            noteDate: when,
            createdAt: when,
            updatedAt: when,
            body: const Value('Herbstwald'),
          ),
        );
    await oldDb.customStatement(
      'INSERT INTO notes_fts(rowid, body, tags, place, title, country, song) '
      "VALUES (1, 'Herbstwald', '', '', '', '', '')",
    );
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    final repo = DriftNoteRepository(db);
    expect(
      await repo.watchJournal(const JournalQuery(text: 'herbstwald')).first,
      hasLength(1),
    );
    await repo.save(
      NoteDraft(assetId: '52', body: 'Neu', date: DateTime(2025, 9, 2)),
    );
    final uids = (await db.select(db.notes).get()).map((n) => n.uid).toSet();
    expect(uids, hasLength(2));
    await db.close();
  });
}
