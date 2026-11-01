import 'package:drift/drift.dart';

import '../../../core/async/distinct_collections.dart';
import '../../../core/database/app_database.dart';
import '../../../core/search/fts_query.dart';
import '../../music/domain/song.dart';
import '../../tags/domain/tag.dart';
import '../../weather/domain/weather.dart';
import '../domain/note.dart';

class DriftNoteRepository implements NoteRepository {
  DriftNoteRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  /// Characters of note text loaded for list previews.
  static const previewLength = 400;

  @override
  Future<Note?> findByAsset(String assetId) async {
    final row = await (_db.select(
      _db.notes,
    )..where((n) => n.assetId.equals(assetId))).getSingleOrNull();
    if (row == null) return null;
    return _toNote(row, await _tagsFor(row.id));
  }

  @override
  Stream<Note?> watchByAsset(String assetId) {
    final query = _db.select(_db.notes)
      ..where((n) => n.assetId.equals(assetId));
    return query.watchSingleOrNull().asyncMap((row) async {
      if (row == null) return null;
      return _toNote(row, await _tagsFor(row.id));
    });
  }

  @override
  Future<Note> save(NoteDraft draft) {
    return _db.transaction(() async {
      final now = _clock();
      final existing = await (_db.select(
        _db.notes,
      )..where((n) => n.assetId.equals(draft.assetId))).getSingleOrNull();
      final companion = NotesCompanion(
        body: Value(draft.body),
        title: Value(_clean(draft.title)),
        photoAspect: draft.photoAspect == null
            ? const Value.absent()
            : Value(draft.photoAspect),
        noteDate: Value(draft.date),
        weatherKind: Value(draft.weather?.kind.name),
        temperatureC: Value(draft.weather?.temperatureC),
        placeName: draft.keepStoredGeo
            ? const Value.absent()
            : Value(_clean(draft.placeName)),
        // The second name belongs to the place: no place, no second name.
        placeNameAlt: draft.keepStoredGeo
            ? const Value.absent()
            : Value(
                _clean(draft.placeName) == null
                    ? null
                    : _clean(draft.placeNameAlt),
              ),
        countryCode: draft.keepStoredGeo
            ? const Value.absent()
            : Value(_clean(draft.countryCode)?.toUpperCase()),
        // Once looked up (or chosen), a note never goes back to the queue.
        geoChecked: draft.geoChecked ? const Value(true) : const Value.absent(),
        songUri: Value(draft.song?.uri),
        songTitle: Value(_clean(draft.song?.title)),
        songArtist: Value(_clean(draft.song?.artist)),
        songCoverFile: Value(draft.song?.coverFile),
        updatedAt: Value(now),
      );
      final int id;
      if (existing == null) {
        id = await _db
            .into(_db.notes)
            .insert(
              companion.copyWith(
                assetId: Value(draft.assetId),
                createdAt: Value(now),
              ),
            );
      } else {
        id = existing.id;
        await (_db.update(
          _db.notes,
        )..where((n) => n.id.equals(id))).write(companion);
      }

      await (_db.delete(_db.noteTags)..where((t) => t.noteId.equals(id))).go();
      if (draft.tagIds.isNotEmpty) {
        await _db.batch(
          (b) => b.insertAll(_db.noteTags, [
            for (final tagId in draft.tagIds)
              NoteTagsCompanion.insert(noteId: id, tagId: tagId),
          ], mode: InsertMode.insertOrIgnore),
        );
      }
      await _db.searchIndex.reindexNote(id);

      final row = await (_db.select(
        _db.notes,
      )..where((n) => n.id.equals(id))).getSingle();
      return _toNote(row, await _tagsFor(id));
    });
  }

  @override
  Future<void> setThumbnailFile(int noteId, String? fileName) =>
      (_db.update(_db.notes)..where((n) => n.id.equals(noteId))).write(
        NotesCompanion(thumbnailFile: Value(fileName)),
      );

  @override
  Future<void> setPhotoAspect(int noteId, double aspect) =>
      (_db.update(_db.notes)..where((n) => n.id.equals(noteId))).write(
        NotesCompanion(photoAspect: Value(aspect)),
      );

  @override
  Future<List<({int id, String assetId, String? thumbnailFile})>>
  notesWithoutPhotoAspect() async {
    final rows = await (_db.select(
      _db.notes,
    )..where((n) => n.photoAspect.isNull())).get();
    return [
      for (final r in rows)
        (id: r.id, assetId: r.assetId, thumbnailFile: r.thumbnailFile),
    ];
  }

  @override
  Future<List<({int id, String assetId, String? placeName})>>
  notesNeedingGeo() async {
    final rows =
        await (_db.select(_db.notes)
              ..where((n) => n.geoChecked.equals(false))
              ..orderBy([(n) => OrderingTerm.desc(n.noteDate)]))
            .get();
    return [
      for (final r in rows)
        (id: r.id, assetId: r.assetId, placeName: r.placeName),
    ];
  }

  @override
  Future<void> setGeo(
    int noteId, {
    String? countryCode,
    String? placeName,
    String? placeNameAlt,
  }) {
    return _db.transaction(() async {
      final row = await (_db.select(
        _db.notes,
      )..where((n) => n.id.equals(noteId))).getSingleOrNull();
      if (row == null) return;
      final keepPlace = row.placeName != null;
      await (_db.update(_db.notes)..where((n) => n.id.equals(noteId))).write(
        NotesCompanion(
          geoChecked: const Value(true),
          countryCode: row.countryCode == null && countryCode != null
              ? Value(countryCode.toUpperCase())
              : const Value.absent(),
          placeName: keepPlace || _clean(placeName) == null
              ? const Value.absent()
              : Value(_clean(placeName)),
          placeNameAlt: _clean(placeNameAlt) == null
              ? const Value.absent()
              : keepPlace
              // Only add the second name if it belongs to the kept place.
              ? (row.placeNameAlt == null &&
                        row.placeName!.toLowerCase() ==
                            _clean(placeName)?.toLowerCase()
                    ? Value(_clean(placeNameAlt))
                    : const Value.absent())
              : Value(_clean(placeNameAlt)),
        ),
      );
      await _db.searchIndex.reindexNote(noteId);
    });
  }

  @override
  Stream<Map<String, int>> watchCountryCounts() {
    final count = _db.notes.id.count();
    final query = _db.selectOnly(_db.notes)
      ..addColumns([_db.notes.countryCode, count])
      ..where(_db.notes.countryCode.isNotNull())
      ..groupBy([_db.notes.countryCode]);
    return query
        .watch()
        .map(
          (rows) => {
            for (final r in rows)
              r.read(_db.notes.countryCode)!: r.read(count) ?? 0,
          },
        )
        .distinctMaps();
  }

  @override
  Stream<List<PlaceUse>> watchPlaces() {
    return _db
        .customSelect(
          '''
SELECT place_name, MAX(country_code) AS country_code, COUNT(*) AS uses
FROM notes WHERE place_name IS NOT NULL
GROUP BY lower(place_name)
ORDER BY uses DESC, place_name''',
          readsFrom: {_db.notes},
        )
        .watch()
        .map(
          (rows) => [
            for (final r in rows)
              PlaceUse(
                name: r.read<String>('place_name'),
                countryCode: r.readNullable<String>('country_code'),
                count: r.read<int>('uses'),
              ),
          ],
        )
        .distinctLists();
  }

  @override
  Future<String?> deleteByAsset(String assetId) {
    return _db.transaction(() async {
      final row = await (_db.select(
        _db.notes,
      )..where((n) => n.assetId.equals(assetId))).getSingleOrNull();
      if (row == null) return null;
      await _db.searchIndex.removeNote(row.id);
      await (_db.delete(_db.notes)..where((n) => n.id.equals(row.id))).go();
      return row.thumbnailFile;
    });
  }

  @override
  Stream<Set<String>> watchNotedAssetIds() {
    final query = _db.selectOnly(_db.notes)..addColumns([_db.notes.assetId]);
    return query
        .watch()
        .map((rows) => rows.map((r) => r.read(_db.notes.assetId)!).toSet())
        .distinctSets();
  }

  @override
  Future<int> count() async {
    final countExp = _db.notes.id.count();
    final query = _db.selectOnly(_db.notes)..addColumns([countExp]);
    return (await query.getSingle()).read(countExp) ?? 0;
  }

  @override
  Stream<List<NoteSummary>> watchJournal(JournalQuery query) {
    final match = buildFtsQuery(query.text);
    final variables = <Variable<Object>>[];
    final where = <String>[];
    var from = 'notes n';
    var snippetColumn = 'NULL';
    var titleColumn = 'NULL';

    if (match != null) {
      from = 'notes n JOIN notes_fts f ON f.rowid = n.id';
      where.add('notes_fts MATCH ?');
      variables.add(Variable.withString(match));
      snippetColumn = "snippet(notes_fts, 0, char(2), char(3), '…', 24)";
      // The whole title with hits marked (column 3 = title).
      titleColumn = 'highlight(notes_fts, 3, char(2), char(3))';
    }
    if (query.tagIds.isNotEmpty) {
      final placeholders = List.filled(query.tagIds.length, '?').join(', ');
      where.add(
        'n.id IN (SELECT note_id FROM note_tags '
        'WHERE tag_id IN ($placeholders) GROUP BY note_id '
        'HAVING COUNT(DISTINCT tag_id) = ${query.tagIds.length})',
      );
      variables.addAll(query.tagIds.map(Variable.withInt));
    }
    if (query.placeName != null) {
      where.add('lower(n.place_name) = lower(?)');
      variables.add(Variable.withString(query.placeName!));
    }
    if (query.countryCode != null) {
      where.add('n.country_code = ?');
      variables.add(Variable.withString(query.countryCode!));
    }
    if (query.collectionId != null) {
      where.add(
        'n.id IN (SELECT note_id FROM collection_notes WHERE collection_id = ?)',
      );
      variables.add(Variable.withInt(query.collectionId!));
    }
    final order = query.oldestFirst ? 'ASC' : 'DESC';

    final sql =
        '''
SELECT n.id, n.asset_id, n.note_date, n.weather_kind, n.temperature_c,
       n.thumbnail_file, n.place_name, n.country_code,
       n.title, n.photo_aspect,
       n.song_uri, n.song_title, n.song_artist, n.song_cover_file,
       substr(n.body, 1, $previewLength) AS preview,
       $snippetColumn AS snippet, $titleColumn AS title_marked
FROM $from
${where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}'}
ORDER BY n.note_date $order, n.id $order''';

    final readsFrom = <ResultSetImplementation<dynamic, dynamic>>{
      _db.notes,
      _db.noteTags,
      _db.tags,
      if (match != null) _db.notesFts,
      if (query.collectionId != null) _db.collectionNotes,
    };

    return _db
        .customSelect(sql, variables: variables, readsFrom: readsFrom)
        .watch()
        .asyncMap((rows) async {
          final ids = rows.map((r) => r.read<int>('id')).toList();
          final tagsByNote = await _tagsForMany(ids);
          return [
            for (final r in rows)
              NoteSummary(
                id: r.read<int>('id'),
                assetId: r.read<String>('asset_id'),
                date: _readDate(r.read<int>('note_date')),
                preview: r.read<String>('preview'),
                weather: _weather(
                  r.readNullable<String>('weather_kind'),
                  r.readNullable<double>('temperature_c'),
                ),
                thumbnailFile: r.readNullable<String>('thumbnail_file'),
                tags: tagsByNote[r.read<int>('id')] ?? const [],
                highlightedSnippet: r.readNullable<String>('snippet'),
                placeName: r.readNullable<String>('place_name'),
                countryCode: r.readNullable<String>('country_code'),
                title: r.readNullable<String>('title'),
                highlightedTitle: _marked(
                  r.readNullable<String>('title_marked'),
                ),
                photoAspect: r.readNullable<double>('photo_aspect'),
                song: _song(
                  r.readNullable<String>('song_uri'),
                  r.readNullable<String>('song_title'),
                  r.readNullable<String>('song_artist'),
                  r.readNullable<String>('song_cover_file'),
                ),
              ),
          ];
        })
        .distinctLists();
  }

  static String? _clean(String? text) {
    final t = text?.trim();
    return t == null || t.isEmpty ? null : t;
  }

  /// Only keeps a highlighted text if it actually contains a hit.
  static String? _marked(String? text) =>
      text != null && text.contains('\u0002') ? text : null;

  // --- helpers --------------------------------------------------------------

  static DateTime _readDate(int unixSeconds) =>
      DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000);

  static Song? _song(
    String? uri,
    String? title,
    String? artist,
    String? coverFile,
  ) => uri == null
      ? null
      : Song(
          uri: uri,
          title: title ?? '',
          artist: artist ?? '',
          coverFile: coverFile,
        );

  @override
  Future<Set<String>> songCoverFilesInUse() async {
    final rows =
        await (_db.selectOnly(_db.notes, distinct: true)
              ..addColumns([_db.notes.songCoverFile])
              ..where(_db.notes.songCoverFile.isNotNull()))
            .get();
    return {for (final r in rows) r.read(_db.notes.songCoverFile)!};
  }

  static WeatherSnapshot? _weather(String? kind, double? temperature) {
    final parsed = WeatherKind.fromName(kind);
    if (parsed == null) return null;
    return WeatherSnapshot(kind: parsed, temperatureC: temperature);
  }

  Note _toNote(NoteRow row, List<Tag> tags) => Note(
    id: row.id,
    assetId: row.assetId,
    body: row.body,
    date: row.noteDate,
    weather: _weather(row.weatherKind, row.temperatureC),
    thumbnailFile: row.thumbnailFile,
    placeName: row.placeName,
    placeNameAlt: row.placeNameAlt,
    countryCode: row.countryCode,
    geoChecked: row.geoChecked,
    title: row.title,
    photoAspect: row.photoAspect,
    song: _song(row.songUri, row.songTitle, row.songArtist, row.songCoverFile),
    tags: tags,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );

  Future<List<Tag>> _tagsFor(int noteId) async =>
      (await _tagsForMany([noteId]))[noteId] ?? const [];

  Future<Map<int, List<Tag>>> _tagsForMany(List<int> noteIds) async {
    if (noteIds.isEmpty) return const {};
    final result = <int, List<Tag>>{};
    // Stay well below SQLite's variable limit.
    const chunkSize = 500;
    for (var i = 0; i < noteIds.length; i += chunkSize) {
      final chunk = noteIds.sublist(
        i,
        i + chunkSize > noteIds.length ? noteIds.length : i + chunkSize,
      );
      final query =
          _db.select(_db.noteTags).join([
              innerJoin(_db.tags, _db.tags.id.equalsExp(_db.noteTags.tagId)),
            ])
            ..where(_db.noteTags.noteId.isIn(chunk))
            ..orderBy([
              OrderingTerm.asc(_db.tags.name.collate(Collate.noCase)),
            ]);
      for (final row in await query.get()) {
        final tag = row.readTable(_db.tags);
        result
            .putIfAbsent(row.readTable(_db.noteTags).noteId, () => [])
            .add(Tag(id: tag.id, name: tag.name, emoji: tag.emoji));
      }
    }
    return result;
  }
}
