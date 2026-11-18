import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/app/providers.dart';
import 'package:randnotiz/core/database/app_database.dart';
import 'package:randnotiz/features/geo/data/geo_database.dart';
import 'package:randnotiz/features/library/data/imported_photo_store.dart';
import 'package:randnotiz/features/library/domain/photo_repository.dart';
import 'package:randnotiz/features/music/domain/song_candidate.dart';
import 'package:randnotiz/features/notes/data/drift_note_repository.dart';
import 'package:randnotiz/features/notes/data/thumbnail_store.dart';
import 'package:randnotiz/features/notes/domain/note.dart';
import 'package:randnotiz/features/notes/domain/song.dart';
import 'package:randnotiz/features/notes/presentation/note_editor_controller.dart';
import 'package:randnotiz/features/weather/domain/weather.dart';

import '../music/fake_music_service.dart';

class _NoPhotos implements PhotoRepository {
  @override
  Future<PhotoItem?> findById(String id) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoWeather implements WeatherProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Saves through Drift, but can fail or wait on request.
class _ControlledNotes extends DriftNoteRepository {
  _ControlledNotes(super.db);

  int failNext = 0;
  Completer<void>? gate;

  @override
  Future<Note> save(NoteDraft draft) async {
    if (failNext > 0) {
      failNext--;
      throw StateError('disk full');
    }
    await gate?.future;
    return super.save(draft);
  }
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late _ControlledNotes notes;
  late Directory dir;
  late ProviderContainer container;
  late FakeMusicService music;

  setUp(() async {
    music = FakeMusicService(cover: Uint8List.fromList([0xFF, 0xD8, 0xFF]));
    db = AppDatabase(NativeDatabase.memory());
    notes = _ControlledNotes(db);
    dir = await Directory.systemTemp.createTemp('randnotiz_editor_');
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        noteRepositoryProvider.overrideWithValue(notes),
        photoRepositoryProvider.overrideWithValue(_NoPhotos()),
        weatherProviderProvider.overrideWithValue(_NoWeather()),
        thumbnailStoreProvider.overrideWithValue(
          ThumbnailStore(Directory('${dir.path}/thumbs')),
        ),
        importedPhotoStoreProvider.overrideWithValue(
          ImportedPhotoStore(Directory('${dir.path}/imported')),
        ),
        geoDatabaseProvider.overrideWith(
          (ref) => Completer<GeoDatabase>().future,
        ),
        musicServiceProvider.overrideWithValue(music),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await db.close();
    await dir.delete(recursive: true);
  });

  /// Opens the editor of [assetId] and waits until it has loaded.
  Future<NoteEditorController> open(String assetId) async {
    container.listen(noteEditorProvider(assetId), (_, _) {});
    while (container.read(noteEditorProvider(assetId)).loading) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    return container.read(noteEditorProvider(assetId).notifier);
  }

  NoteEditorState stateOf(String assetId) =>
      container.read(noteEditorProvider(assetId));

  Future<void> close() async {
    container.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  test('a linked song is stored with its cover, and can be removed', () async {
    final editor = await open('s2');
    editor.setBody('Sommerabend');
    await editor.setSong(
      const SongCandidate(
        uri: 'itunes:track:1440857781',
        title: 'Lied',
        artist: 'Band',
        coverUrl: 'https://is1-ssl.mzstatic.com/image/thumb/x/600x600bb.jpg',
      ),
    );
    await editor.flush();
    var saved = await notes.findByAsset('s2');
    expect(saved!.song?.uri, 'itunes:track:1440857781');
    expect(saved.song?.coverFile, 'song_itunes_1440857781.jpg');
    expect(
      File('${dir.path}/thumbs/song_itunes_1440857781.jpg').existsSync(),
      isTrue,
    );

    editor.removeSong();
    await editor.flush();
    saved = await notes.findByAsset('s2');
    expect(saved!.song, isNull);
    expect(saved.body, 'Sommerabend');
  });

  test('a linked song survives editing', () async {
    const song = Song(
      uri: 'itunes:track:1',
      title: 'Lied',
      artist: 'Band',
      coverFile: 'song_1.jpg',
    );
    await notes.save(
      NoteDraft(
        assetId: 's1',
        body: 'Konzert',
        date: DateTime(2025),
        song: song,
      ),
    );
    final editor = await open('s1');
    editor.setBody('Konzert im Park');
    await editor.flush();
    final saved = await notes.findByAsset('s1');
    expect(saved!.body, 'Konzert im Park');
    expect(saved.song, song);
  });

  test('a failed save is shown and tried again', () async {
    final editor = await open('a1');
    notes.failNext = 1;
    editor.setBody('Hallo');
    await editor.flush();
    expect(stateOf('a1').saveStatus, SaveStatus.failed);
    expect(await notes.findByAsset('a1'), isNull);

    // The retry is scheduled; flushing runs it now.
    await editor.flush();
    expect(stateOf('a1').saveStatus, SaveStatus.saved);
    expect((await notes.findByAsset('a1'))!.body, 'Hallo');
  });

  test('weather arriving while the note is first saved is kept', () async {
    final editor = await open('a2');
    notes.gate = Completer<void>();
    editor.setBody('Strandtag');
    final first = editor.flush();
    await Future<void>.delayed(const Duration(milliseconds: 5));
    // The note does not exist yet – it is being created.
    editor.setWeatherManually(
      const WeatherSnapshot(kind: WeatherKind.clear, temperatureC: 28),
    );
    notes.gate!.complete();
    await first;
    await editor.flush();
    final saved = await notes.findByAsset('a2');
    expect(saved!.weather?.kind, WeatherKind.clear);
  });

  test('an emptied note stays while open, can be brought back, and is '
      'deleted on closing', () async {
    await notes.save(
      NoteDraft(assetId: 'a3', body: 'Erster Schnee', date: DateTime(2025)),
    );
    final editor = await open('a3');
    editor.setBody('');
    expect(editor.clearedContent?.body, 'Erster Schnee');
    await editor.flush();
    expect(await notes.findByAsset('a3'), isNotNull, reason: 'kept while open');

    expect(editor.undoClear()?.body, 'Erster Schnee');
    expect(editor.clearedContent, isNull);
    await editor.flush();
    expect((await notes.findByAsset('a3'))!.body, 'Erster Schnee');

    editor.setBody('   ');
    await editor.flush();
    await close();
    expect(await notes.findByAsset('a3'), isNull, reason: 'deleted on close');
  });

  test('an empty new note is never created', () async {
    final editor = await open('a4');
    editor.setBody('x');
    editor.setBody('');
    await editor.flush();
    await close();
    expect(await notes.findByAsset('a4'), isNull);
  });

  test(
    'the editor does not undo a place found meanwhile by the back-fill',
    () async {
      final note = await notes.save(
        NoteDraft(assetId: 'a5', body: 'Alte Notiz', date: DateTime(2020)),
      );
      final editor = await open('a5');
      await notes.setGeo(note.id, countryCode: 'IT', placeName: 'Rom');
      editor.setBody('Alte Notiz, ergänzt');
      await editor.flush();
      final saved = await notes.findByAsset('a5');
      expect(saved!.body, 'Alte Notiz, ergänzt');
      expect(saved.countryCode, 'IT');
      expect(saved.placeName, 'Rom');
    },
  );
}
