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
import 'package:randnotiz/features/music/domain/song_candidate.dart';
import 'package:randnotiz/features/music/presentation/apple_music_badge.dart';
import 'package:randnotiz/features/music/presentation/song_record.dart';
import 'package:randnotiz/features/music/presentation/song_sheet.dart';
import 'package:randnotiz/features/music/presentation/vinyl_record.dart';
import 'package:randnotiz/features/notes/data/drift_note_repository.dart';
import 'package:randnotiz/features/notes/data/thumbnail_store.dart';
import 'package:randnotiz/features/notes/domain/note.dart';
import 'package:randnotiz/features/notes/presentation/note_editor_controller.dart';
import 'package:randnotiz/l10n/generated/app_localizations.dart';

import 'fake_music_service.dart';
import 'fake_preview_player.dart';

class _NoPhotos implements PhotoRepository {
  @override
  Future<PhotoItem?> findById(String id) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _candidate = SongCandidate(
  uri: 'itunes:track:1440857781',
  title: 'Knights of Cydonia',
  artist: 'Muse',
  album: 'Black Holes and Revelations',
  coverUrl: 'https://is1-ssl.mzstatic.com/image/thumb/x/600x600bb.jpg',
);

final _preview = Uri.parse('https://audio-ssl.itunes.apple.com/p.m4a');

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
  late FakePreviewPlayer player;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    dir = await Directory.systemTemp.createTemp('randnotiz_music');
    player = FakePreviewPlayer();
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
          previewPlayerProvider.overrideWithValue(player),
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

  Future<void> saveWithSong() => DriftNoteRepository(db).save(
    NoteDraft(
      assetId: 'a1',
      body: 'Mit Lied',
      date: DateTime(2025, 6, 1),
      song: _candidate.toSong(),
    ),
  );

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
    await t.runAsync(saveWithSong);
    final music = FakeMusicService(preview: _preview);
    await pump(t, music);
    final box = t.getRect(find.byType(VinylRecord));
    // The corner of its square lies outside the round record: no tap.
    await t.tapAt(box.topLeft + const Offset(4, 4));
    await t.pump();
    expect(player.calls, isEmpty);
    // Near the rim of the disc: plays.
    await t.tapAt(box.centerLeft + const Offset(4, 0));
    await t.pump();
    expect(player.calls, ['play $_preview']);
    await unmount(t);
  });

  testWidgets('search, link, play, pause and resume a preview', (t) async {
    final music = FakeMusicService(
      results: const [_candidate],
      cover: Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xD9]),
      preview: _preview,
    );
    await pump(t, music);
    expect(find.byType(VinylRecord), findsNothing);

    // From the menu: the search opens.
    await t.tap(find.text('menu'));
    await t.pumpAndSettle();
    expect(find.byType(SongSheet), findsOneWidget);
    expect(find.textContaining('bereitgestellt von Apple'), findsOneWidget);

    // One letter is not sent; typing quickly searches once, after the pause.
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
    expect(saved?.song?.coverFile, 'song_itunes_1440857781.jpg');
    expect(
      File('${dir.path}/thumbs/song_itunes_1440857781.jpg').existsSync(),
      isTrue,
    );

    // Tap: the preview plays (looked up fresh), the record turns.
    await t.tap(find.byType(VinylRecord));
    await t.pump();
    expect(music.lookups, [_candidate.uri]);
    expect(player.calls, ['play $_preview']);
    expect(record(t).spinning, isTrue);

    // Tap again: pause.
    await t.tap(find.byType(VinylRecord));
    await t.pump();
    expect(player.calls.last, 'pause');
    expect(record(t).spinning, isFalse);

    // Paused on this song: tapping resumes it.
    await t.tap(find.byType(VinylRecord));
    await t.pump();
    expect(player.calls.last, 'resume');
    expect(record(t).spinning, isTrue);

    // Leaving the note stops the preview.
    await unmount(t);
    expect(player.calls.last, 'stop');
  });

  testWidgets('a song without preview: a message, nothing plays', (t) async {
    await t.runAsync(saveWithSong);
    await pump(t, FakeMusicService());
    await t.tap(find.byType(VinylRecord));
    await t.pump();
    await t.pump();
    expect(player.calls, isEmpty);
    expect(
      find.text('Für dieses Lied gibt es keine Hörprobe.'),
      findsOneWidget,
    );
    expect(record(t).spinning, isFalse);
    await unmount(t);
  });

  testWidgets('offline: a message instead of the preview', (t) async {
    await t.runAsync(saveWithSong);
    await pump(
      t,
      FakeMusicService(
        linksError: const MusicException(MusicException.network),
      ),
    );
    await t.tap(find.byType(VinylRecord));
    await t.pump();
    await t.pump();
    expect(find.text('Keine Verbindung zu Apple Music.'), findsOneWidget);
    await unmount(t);
  });

  testWidgets('long press: Apple Music badge, other services, remove', (
    t,
  ) async {
    await t.runAsync(saveWithSong);
    await pump(t, FakeMusicService());
    expect(find.byType(VinylRecord), findsOneWidget);

    await t.longPress(find.byType(VinylRecord));
    await t.pumpAndSettle();
    expect(find.byType(AppleMusicBadge), findsOneWidget);
    expect(find.text('Andere Dienste'), findsOneWidget);

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
