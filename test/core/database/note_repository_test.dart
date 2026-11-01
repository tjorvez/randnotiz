import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/core/database/app_database.dart';
import 'package:randnotiz/core/search/highlight.dart';
import 'package:randnotiz/features/geo/data/country_names_sync.dart';
import 'package:randnotiz/features/geo/domain/geo.dart';
import 'package:randnotiz/features/music/domain/song.dart';
import 'package:randnotiz/features/notes/data/drift_note_repository.dart';
import 'package:randnotiz/features/notes/domain/note.dart';
import 'package:randnotiz/features/tags/data/drift_tag_repository.dart';
import 'package:randnotiz/features/tags/domain/tag.dart';
import 'package:randnotiz/features/weather/domain/weather.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late DriftNoteRepository notes;
  late DriftTagRepository tags;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    notes = DriftNoteRepository(db);
    tags = DriftTagRepository(db);
  });
  tearDown(() => db.close());

  Future<Note> write(
    String assetId,
    String body, {
    DateTime? date,
    Set<int> tagIds = const {},
    WeatherSnapshot? weather,
  }) => notes.save(
    NoteDraft(
      assetId: assetId,
      body: body,
      date: date ?? DateTime(2024, 5, 1, 12),
      tagIds: tagIds,
      weather: weather,
    ),
  );

  Future<List<NoteSummary>> search(String text, {Set<int> tagIds = const {}}) =>
      notes.watchJournal(JournalQuery(text: text, tagIds: tagIds)).first;

  group('notes', () {
    test('title is saved, cleaned, searchable and highlighted', () async {
      final saved = await notes.save(
        NoteDraft(
          assetId: 't1',
          body: 'Wir sind bis zum Leuchtturm gelaufen.',
          title: '  Sonntag am Meer  ',
          date: DateTime(2024, 7, 7),
          photoAspect: 0.75,
        ),
      );
      expect(saved.title, 'Sonntag am Meer');
      expect(saved.photoAspect, 0.75);

      final hits = await search('meer');
      expect(hits.single.title, 'Sonntag am Meer');
      expect(
        parseHighlights(hits.single.highlightedTitle!)
            .where((p) => p.isMatch)
            .single
            .text,
        'Meer',
      );
      // A hit only in the body leaves the title unmarked.
      expect((await search('leuchtt')).single.highlightedTitle, isNull);

      // An empty title is stored as "no title"; a null aspect keeps the old.
      final cleared = await notes.save(
        NoteDraft(
          assetId: 't1',
          body: 'Wir sind bis zum Leuchtturm gelaufen.',
          title: '   ',
          date: DateTime(2024, 7, 7),
        ),
      );
      expect(cleared.title, isNull);
      expect(cleared.photoAspect, 0.75);
      expect(await search('meer'), isEmpty);
    });

    test('song: saved, listed, searchable, removable, covers in use', () async {
      const song = Song(
        uri: 'spotify:track:7ouMYWpwJ422jRcDASZB7P',
        title: '  Knights of Cydonia ',
        artist: 'Muse',
        coverFile: 'song_7ouMYWpwJ422jRcDASZB7P.jpg',
      );
      final saved = await notes.save(
        NoteDraft(
          assetId: 's1',
          body: '',
          date: DateTime(2024, 6, 1),
          song: song,
        ),
      );
      expect(saved.song?.title, 'Knights of Cydonia', reason: 'trimmed');
      expect(saved.song?.uri, song.uri);
      expect((await search('')).single.song?.artist, 'Muse');
      expect((await search('cydonia')).single.assetId, 's1');
      expect((await search('muse')).single.assetId, 's1');
      expect(await notes.songCoverFilesInUse(), {song.coverFile});

      await notes.save(
        NoteDraft(assetId: 's1', body: 'Nur Text', date: DateTime(2024, 6, 1)),
      );
      expect((await notes.findByAsset('s1'))!.song, isNull);
      expect(await search('muse'), isEmpty);
      expect(await notes.songCoverFilesInUse(), isEmpty);
    });

    test('a song alone is enough to keep a note', () {
      final draft = NoteDraft(
        assetId: 'x',
        body: ' ',
        date: DateTime(2024),
        song: const Song(uri: 'spotify:track:1', title: 'A', artist: 'B'),
      );
      expect(draft.isBlank, isFalse);
    });

    test('a title alone is enough to keep a note', () {
      expect(
        NoteDraft(
          assetId: 'x',
          body: ' ',
          title: 'Nur ein Titel',
          date: DateTime(2024),
        ).isBlank,
        isFalse,
      );
      expect(
        NoteDraft(
          assetId: 'x',
          body: ' ',
          title: ' ',
          date: DateTime(2024),
        ).isBlank,
        isTrue,
      );
    });

    test('photo aspect back-fill finds and updates notes', () async {
      final a = await write('a1', 'Eins');
      await write('a2', 'Zwei');
      expect(
        (await notes.notesWithoutPhotoAspect()).map((n) => n.assetId),
        unorderedEquals(['a1', 'a2']),
      );
      await notes.setPhotoAspect(a.id, 1.5);
      expect((await notes.findByAsset('a1'))!.photoAspect, 1.5);
      expect((await notes.notesWithoutPhotoAspect()).single.assetId, 'a2');
    });

    test('country and place: stored as names, filtered, searchable in '
        'German and English', () async {
      await CountryNamesSync(db).sync(const [
        Country(
          code: 'NO',
          nameDe: 'Norwegen',
          nameEn: 'Norway',
          isSmall: false,
          marker: GeoPoint(60, 8),
        ),
        Country(
          code: 'DE',
          nameDe: 'Deutschland',
          nameEn: 'Germany',
          isSmall: false,
          marker: GeoPoint(51, 10),
        ),
      ]);
      await notes.save(
        NoteDraft(
          assetId: 'fjord',
          body: 'Fähre über den Fjord',
          date: DateTime(2024, 7, 2),
          placeName: 'Bergen',
          countryCode: 'no',
          geoChecked: true,
        ),
      );
      await notes.save(
        NoteDraft(
          assetId: 'bier',
          body: 'Biergarten',
          date: DateTime(2024, 6, 1),
          placeName: 'München',
          placeNameAlt: 'Munich',
          countryCode: 'DE',
        ),
      );
      final fjord = (await notes.findByAsset('fjord'))!;
      expect(fjord.countryCode, 'NO', reason: 'stored upper case');
      expect(fjord.geoChecked, isTrue);

      // Both languages find the same notes, also the place's second name.
      expect((await search('norwegen')).single.assetId, 'fjord');
      expect((await search('norway')).single.assetId, 'fjord');
      expect((await search('munich')).single.assetId, 'bier');
      expect((await search('germany')).single.countryCode, 'DE');

      // Filters set by suggestion chips.
      final inNorway = await notes
          .watchJournal(const JournalQuery(countryCode: 'NO'))
          .first;
      expect(inNorway.single.assetId, 'fjord');
      final inMunich = await notes
          .watchJournal(const JournalQuery(placeName: 'münchen'))
          .first;
      expect(inMunich.single.assetId, 'bier');

      expect(await notes.watchCountryCounts().first, {'NO': 1, 'DE': 1});
      final places = await notes.watchPlaces().first;
      expect(places.map((p) => p.name), unorderedEquals(['Bergen', 'München']));
      expect(places.firstWhere((p) => p.name == 'Bergen').countryCode, 'NO');

      // No place, no second name.
      final moved = await notes.save(
        NoteDraft(
          assetId: 'bier',
          body: 'Biergarten',
          date: DateTime(2024, 6, 1),
          placeNameAlt: 'Munich',
          countryCode: 'DE',
        ),
      );
      expect(moved.placeName, isNull);
      expect(moved.placeNameAlt, isNull);
      expect(await search('munich'), isEmpty);
    });

    test('back-fill: waiting notes, kept places, marked as checked', () async {
      final typed = await notes.save(
        NoteDraft(
          assetId: 'typed',
          body: 'Prater',
          date: DateTime(2023, 5, 1),
          placeName: 'Wien',
        ),
      );
      final plain = await write('plain', 'Ohne Ort');
      expect(
        (await notes.notesNeedingGeo()).map((n) => n.assetId),
        unorderedEquals(['typed', 'plain']),
      );

      // A place typed in by hand stays; its second name is added if the
      // lookup found the same place.
      await notes.setGeo(
        typed.id,
        countryCode: 'AT',
        placeName: 'Wien',
        placeNameAlt: 'Vienna',
      );
      await notes.setGeo(plain.id, countryCode: 'AT', placeName: 'Salzburg');
      final a = (await notes.findByAsset('typed'))!;
      expect(
        [a.placeName, a.placeNameAlt, a.countryCode],
        ['Wien', 'Vienna', 'AT'],
      );
      expect((await notes.findByAsset('plain'))!.placeName, 'Salzburg');
      expect(await notes.notesNeedingGeo(), isEmpty);
      expect((await search('vienna')).single.assetId, 'typed');

      // A country chosen by hand is not overwritten by a later lookup.
      await notes.setGeo(plain.id, countryCode: 'DE');
      expect((await notes.findByAsset('plain'))!.countryCode, 'AT');
    });

    test('save creates, then updates the same asset', () async {
      final created = await write(
        '42',
        'Erster Tag am Meer',
        weather: const WeatherSnapshot(
          kind: WeatherKind.clear,
          temperatureC: 21.5,
        ),
      );
      final updated = await write('42', 'Erster Tag am Meer, windig');

      expect(updated.id, created.id);
      expect(await notes.count(), 1);
      final loaded = await notes.findByAsset('42');
      expect(loaded!.body, 'Erster Tag am Meer, windig');
      expect(loaded.weather, isNull, reason: 'draft without weather clears it');
    });

    test('stores weather and date', () async {
      final date = DateTime(2023, 7, 14, 18, 30);
      await write(
        '1',
        'x',
        date: date,
        weather: const WeatherSnapshot(
          kind: WeatherKind.rain,
          temperatureC: 12.3,
        ),
      );
      final loaded = await notes.findByAsset('1');
      expect(loaded!.date, date);
      expect(
        loaded.weather,
        const WeatherSnapshot(kind: WeatherKind.rain, temperatureC: 12.3),
      );
    });

    test('delete removes note, tag links and index entry', () async {
      final tag = await tags.createTag('Urlaub', emoji: '😊');
      final note = await write('7', 'Sonnenuntergang', tagIds: {tag.id});
      await notes.setThumbnailFile(note.id, 'thumb_7.jpg');

      expect(await notes.deleteByAsset('7'), 'thumb_7.jpg');
      expect(await notes.findByAsset('7'), isNull);
      expect(await search('Sonnen'), isEmpty);
      expect(await db.select(db.noteTags).get(), isEmpty);
      expect(await notes.deleteByAsset('7'), isNull);
    });

    test('noted asset ids stream reflects changes', () async {
      final stream = notes.watchNotedAssetIds();
      expect(await stream.first, isEmpty);
      await write('a', 'x');
      await write('b', 'y');
      expect(await stream.first, {'a', 'b'});
    });

    test(
      'streams skip results that did not change (autosave of the text)',
      () async {
        final t = await tags.createTag('Meer', emoji: '🌊');
        final long = 'a' * (DriftNoteRepository.previewLength + 10);
        await write('a', long, tagIds: {t.id});

        final ids = <Set<String>>[];
        final journal = <List<NoteSummary>>[];
        final usage = <Map<int, int>>[];
        final subs = [
          notes.watchNotedAssetIds().listen(ids.add),
          notes.watchJournal(const JournalQuery()).listen(journal.add),
          tags.watchUsageCounts().listen(usage.add),
        ];
        Future<void> settle() =>
            Future<void>.delayed(const Duration(milliseconds: 50));
        await settle();
        expect([ids.length, journal.length, usage.length], [1, 1, 1]);

        // Typing beyond the preview changes nothing any list shows.
        for (var i = 0; i < 3; i++) {
          await write('a', '$long$i', tagIds: {t.id});
          await settle();
        }
        expect([ids.length, journal.length, usage.length], [1, 1, 1]);

        // A real change still arrives.
        await write('b', 'neu');
        await settle();
        expect(ids.last, {'a', 'b'});
        expect(journal.last, hasLength(2));
        for (final s in subs) {
          await s.cancel();
        }
      },
    );

    test('journal is ordered newest first and carries tags', () async {
      final t = await tags.createTag('Familie', emoji: '😊');
      await write('old', 'alt', date: DateTime(2020, 1, 1));
      await write('new', 'neu', date: DateTime(2024, 1, 1), tagIds: {t.id});
      final all = await search('');
      expect(all.map((e) => e.assetId), ['new', 'old']);
      expect(all.first.tags.single.name, 'Familie');
      expect(all.first.highlightedSnippet, isNull);
    });
  });

  group('tags', () {
    test(
      'duplicate names are rejected case-insensitively, incl. umlauts',
      () async {
        await tags.createTag('Ärger', emoji: '😊');
        expect(
          () => tags.createTag('ärger', emoji: '😊'),
          throwsA(isA<DuplicateTagNameException>()),
        );
        expect(
          () => tags.createTag('  ÄRGER ', emoji: '😊'),
          throwsA(isA<DuplicateTagNameException>()),
        );
      },
    );

    test('rename and delete keep notes and update search', () async {
      final tag = await tags.createTag('Reise', emoji: '😊');
      await write('1', 'Ein schöner Tag', tagIds: {tag.id});

      expect(await search('reise'), hasLength(1));
      await tags.renameTag(tag.id, 'Wanderung');
      expect(await search('reise'), isEmpty);
      expect(await search('wander'), hasLength(1));

      await tags.deleteTag(tag.id);
      expect(await search('wander'), isEmpty);
      expect((await notes.findByAsset('1'))!.tags, isEmpty);
      expect(await notes.count(), 1);
    });

    test('usage counts', () async {
      final a = await tags.createTag('A', emoji: '😊');
      final b = await tags.createTag('B', emoji: '😊');
      await write('1', 'x', tagIds: {a.id, b.id});
      await write('2', 'y', tagIds: {a.id});
      expect(await tags.watchUsageCounts().first, {a.id: 2, b.id: 1});
    });
  });

  group('full-text search', () {
    setUp(() async {
      await write('1', 'Heute mit dem Mädchen im München Zoo gewesen.');
      await write('2', 'Spaziergang durch die Straße am Fluss');
      await write('3', 'Großer Ärger mit dem Auto, KAPUTT');
    });

    Future<List<String>> ids(String q) async =>
        (await search(q)).map((e) => e.assetId).toList();

    test('prefix search', () async {
      expect(await ids('Spazier'), ['2']);
      expect(await ids('zo'), ['1']);
    });

    test('case insensitive', () async {
      expect(await ids('kaputt'), ['3']);
      expect(await ids('HEUTE'), ['1']);
    });

    test('umlaut tolerant in all spellings', () async {
      expect(await ids('mädchen'), ['1']);
      expect(await ids('madchen'), ['1']);
      expect(await ids('maedchen'), ['1']);
      expect(await ids('muenchen'), ['1']);
      expect(await ids('arger'), ['3']);
    });

    test('ß and ss are interchangeable', () async {
      expect(await ids('strasse'), ['2']);
      expect(await ids('straße'), ['2']);
      expect(await ids('gross'), ['3']);
    });

    test('all words must match', () async {
      expect(await ids('mädchen zoo'), ['1']);
      expect(await ids('mädchen auto'), isEmpty);
    });

    test('FTS syntax in user input is harmless', () async {
      expect(await ids('"zoo'), ['1']);
      expect(await ids('zoo*'), ['1']);
      expect(await ids('NOT AND OR NEAR'), isEmpty);
      expect(await ids('-:^()'), hasLength(3), reason: 'no words → no filter');
    });

    test('hits are marked in the snippet', () async {
      final result = await search('münch');
      final parts = parseHighlights(result.single.highlightedSnippet!);
      expect(parts.where((p) => p.isMatch).map((p) => p.text), ['München']);
    });

    test('tag names are searchable and combinable with tag filter', () async {
      final tag = await tags.createTag('Sommerferien', emoji: '😊');
      await write(
        '2',
        'Spaziergang durch die Straße am Fluss',
        tagIds: {tag.id},
      );
      expect(await ids('sommer'), ['2']);
      expect(await ids(''), hasLength(3));
      expect((await search('', tagIds: {tag.id})).map((e) => e.assetId), ['2']);
      expect((await search('zoo', tagIds: {tag.id})), isEmpty);
    });

    test('place names are stored, trimmed and searchable', () async {
      await notes.save(
        NoteDraft(
          assetId: '2',
          body: 'Spaziergang durch die Straße am Fluss',
          date: DateTime(2024, 5, 1),
          placeName: '  München ',
        ),
      );
      expect((await notes.findByAsset('2'))!.placeName, 'München');
      expect(await ids('muenchen'), containsAll(['1', '2']));
      final hit = (await search('fluss')).single;
      expect(hit.placeName, 'München');

      await notes.save(
        NoteDraft(assetId: '2', body: 'ohne Ort', date: DateTime(2024, 5, 1)),
      );
      expect((await notes.findByAsset('2'))!.placeName, isNull);
    });

    test('tag filter requires all selected tags', () async {
      final a = await tags.createTag('A', emoji: '😊');
      final b = await tags.createTag('B', emoji: '😊');
      await write('1', 'eins', tagIds: {a.id, b.id});
      await write('2', 'zwei', tagIds: {a.id});
      expect((await search('', tagIds: {a.id})).length, 2);
      expect((await search('', tagIds: {a.id, b.id})).map((e) => e.assetId), [
        '1',
      ]);
    });
  });

  test('search stays fast with thousands of notes', () async {
    final words = [
      'Sonne',
      'Regen',
      'Garten',
      'Kaffee',
      'Bahnhof',
      'Oma',
      'Geburtstag',
      'Wald',
      'Konzert',
      'Strand',
    ];
    await db.batch((b) {
      for (var i = 0; i < 5000; i++) {
        b.insert(
          db.notes,
          NotesCompanion.insert(
            assetId: 'bulk$i',
            body: Value(
              'Eintrag $i: ${words[i % 10]} und ${words[(i * 7) % 10]} '
                      'mit etwas mehr Text, damit es realistisch lang wird. ' *
                  3,
            ),
            noteDate: DateTime(2015).add(Duration(hours: i * 13)),
            createdAt: DateTime(2024),
            updatedAt: DateTime(2024),
          ),
        );
      }
    });
    await db.searchIndex.rebuildAll();

    final sw = Stopwatch()..start();
    final hits = await search('geburt garten');
    sw.stop();
    expect(hits, hasLength(500));
    expect(
      sw.elapsedMilliseconds,
      lessThan(1500),
      reason: 'took ${sw.elapsedMilliseconds} ms for ${hits.length} hits',
    );
  });
}
