import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/app/providers.dart';
import 'package:randnotiz/core/database/app_database.dart';
import 'package:randnotiz/core/theme/app_theme.dart';
import 'package:randnotiz/core/theme/season.dart';
import 'package:randnotiz/features/geo/data/geo_database.dart';
import 'package:randnotiz/features/library/data/imported_photo_store.dart';
import 'package:randnotiz/features/library/domain/photo_repository.dart';
import 'package:randnotiz/features/music/domain/music_service.dart';
import 'package:randnotiz/features/music/domain/song.dart';
import 'package:randnotiz/features/music/presentation/song_record.dart';
import 'package:randnotiz/features/music/presentation/song_sheet.dart';
import 'package:randnotiz/features/music/presentation/vinyl_record.dart';
import 'package:randnotiz/features/notes/data/drift_note_repository.dart';
import 'package:randnotiz/features/notes/data/thumbnail_store.dart';
import 'package:randnotiz/features/notes/domain/note.dart';
import 'package:randnotiz/features/notes/presentation/note_editor_controller.dart';
import 'package:randnotiz/l10n/generated/app_localizations.dart';

import 'fake_music_service.dart';

class _NoPhotos implements PhotoRepository {
  @override
  Future<PhotoItem?> findById(String id) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _candidate = SongCandidate(
  uri: 'spotify:track:7ouMYWpwJ422jRcDASZB7P',
  title: 'Knights of Cydonia',
  artist: 'Muse',
  album: 'Black Holes and Revelations',
  coverUrl: 'https://i.scdn.co/image/large',
);

/// Keeps the (auto-disposed) editor state alive like the editor page does.
class _Host extends ConsumerWidget {
  const _Host();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(noteEditorProvider('a1'));
    return Column(
      children: [
        // Stands in for the note's ⋮ menu entry "Lied hinzufügen".
        TextButton(
          onPressed: () => SongSheet.show(context, assetId: 'a1'),
          child: const Text('menu'),
        ),
        const SongRecord(assetId: 'a1', size: 120),
      ],
    );
  }
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late Directory dir;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    dir = await Directory.systemTemp.createTemp('randnotiz_music');
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  /// Real time for the database and files, then let the UI catch up.
  Future<void> settle(WidgetTester t) async {
    for (var i = 0; i < 6; i++) {
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await t.pump(const Duration(milliseconds: 200));
    }
  }

  Future<void> pump(WidgetTester t, MusicService music) async {
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          photoRepositoryProvider.overrideWithValue(_NoPhotos()),
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
        child: MaterialApp(
          theme: AppTheme.build(Brightness.light, Season.autumn),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: const Scaffold(body: _Host()),
        ),
      ),
    );
    await settle(t);
  }

  VinylRecord record(WidgetTester t) => t.widget(find.byType(VinylRecord));

  Future<void> unmount(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 1));
  }

  testWidgets('without a song there is no record', (t) async {
    await pump(t, FakeMusicService());
    expect(find.byType(VinylRecord), findsNothing);
    await unmount(t);
  });

  testWidgets('the record takes taps on its whole disc, not beside it', (
    t,
  ) async {
    await t.runAsync(
      () => DriftNoteRepository(db).save(
        NoteDraft(
          assetId: 'a1',
          body: '',
          date: DateTime(2025, 6, 1),
          song: _candidate.toSong(),
        ),
      ),
    );
    final music = FakeMusicService();
    await pump(t, music);
    final box = t.getRect(find.byType(VinylRecord));
    // The corner of its square lies outside the round record (on the
    // polaroid in the editor): no tap.
    await t.tapAt(box.topLeft + const Offset(4, 4));
    await t.pump();
    expect(music.calls, isEmpty);
    // Near the rim of the disc: plays.
    await t.tapAt(box.centerLeft + const Offset(4, 0));
    await t.pump();
    expect(music.calls, ['play ${_candidate.uri}']);
    await unmount(t);
  });

  testWidgets('search, link, play and pause a song', (t) async {
    final music = FakeMusicService(
      results: const [_candidate],
      cover: Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xD9]),
    );
    await pump(t, music);
    expect(find.byType(VinylRecord), findsNothing);

    // From the menu: the search opens.
    await t.tap(find.text('menu'));
    await t.pumpAndSettle();
    expect(find.byType(SongSheet), findsOneWidget);

    // Typing quickly searches once, after the pause.
    for (final text in ['k', 'kn', 'knights']) {
      await t.enterText(find.byType(TextField), text);
      await t.pump(const Duration(milliseconds: 100));
    }
    expect(music.searches, isEmpty);
    await t.pump(SongSheet.debounce);
    await settle(t);
    expect(music.searches, ['knights']);
    expect(find.text('Knights of Cydonia'), findsOneWidget);

    // Pick it: linked with its cover, the note is saved.
    await t.tap(find.text('Knights of Cydonia'));
    await settle(t);
    // Storing the cover takes a few real file operations.
    await settle(t);
    await settle(t);
    expect(find.byType(SongSheet), findsNothing);
    expect(find.byType(VinylRecord), findsOneWidget);
    final saved = await t.runAsync(
      () => DriftNoteRepository(db).findByAsset('a1'),
    );
    expect(saved?.song?.uri, _candidate.uri);
    expect(saved?.song?.coverFile, 'song_7ouMYWpwJ422jRcDASZB7P.jpg');
    expect(
      File('${dir.path}/thumbs/song_7ouMYWpwJ422jRcDASZB7P.jpg').existsSync(),
      isTrue,
    );

    // Tap: play – it turns at once and while Spotify reports playing.
    await t.tap(find.byType(VinylRecord));
    await t.pump();
    expect(music.calls, ['play ${_candidate.uri}']);
    expect(record(t).spinning, isTrue);
    music.emit(PlaybackState(uri: _candidate.uri, paused: false));
    await t.pump();
    expect(record(t).spinning, isTrue);

    // Tap again: pause.
    await t.tap(find.byType(VinylRecord));
    await t.pump();
    expect(music.calls.last, 'pause');
    music.emit(PlaybackState(uri: _candidate.uri, paused: true));
    await t.pump();
    expect(record(t).spinning, isFalse);

    // Paused on this song: tapping resumes it.
    await t.tap(find.byType(VinylRecord));
    await t.pump();
    expect(music.calls.last, 'resume');
    await unmount(t);
  });

  testWidgets('long press: the song can be removed', (t) async {
    await t.runAsync(
      () => DriftNoteRepository(db).save(
        NoteDraft(
          assetId: 'a1',
          body: 'Mit Lied',
          date: DateTime(2025, 6, 1),
          song: _candidate.toSong(),
        ),
      ),
    );
    await pump(t, FakeMusicService());
    expect(find.byType(VinylRecord), findsOneWidget);

    await t.longPress(find.byType(VinylRecord));
    await t.pumpAndSettle();
    await t.tap(find.text('Lied entfernen'));
    await settle(t);
    expect(find.byType(VinylRecord), findsNothing);
    final saved = await t.runAsync(
      () => DriftNoteRepository(db).findByAsset('a1'),
    );
    expect(saved?.song, isNull);
    expect(saved?.body, 'Mit Lied', reason: 'the note itself stays');
    await unmount(t);
  });
}
