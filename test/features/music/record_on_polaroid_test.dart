import 'dart:async';
import 'dart:io';

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
import 'package:randnotiz/features/music/domain/song.dart';
import 'package:randnotiz/features/music/presentation/record_on_polaroid.dart';
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

const _pageText = 'Notizseite';

/// The list side: keeps the editor state alive (loaded before the page
/// opens, as when the record is known in time) and opens the note page.
class _Home extends ConsumerWidget {
  const _Home();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(noteEditorProvider('a1'));
    return Scaffold(
      body: TextButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const Scaffold(
              body: Column(
                children: [
                  Text(_pageText),
                  RecordOnPolaroid(
                    assetId: 'a1',
                    polaroidWidth: 240,
                    child: SizedBox(width: 240, height: 280),
                  ),
                ],
              ),
            ),
          ),
        ),
        child: const Text('open'),
      ),
    );
  }
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late Directory dir;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    dir = await Directory.systemTemp.createTemp('randnotiz_record');
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<void> settle(WidgetTester t) async {
    for (var i = 0; i < 6; i++) {
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await t.pump(const Duration(milliseconds: 200));
    }
  }

  /// Opacity of the record (its closest Opacity ancestor).
  double opacity(WidgetTester t) => t
      .widget<Opacity>(
        find
            .ancestor(
              of: find.byType(VinylRecord),
              matching: find.byType(Opacity),
            )
            .first,
      )
      .opacity;

  testWidgets('the record waits for the page, rolls in, and rolls out '
      'before the page closes', (t) async {
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
          home: const _Home(),
        ),
      ),
    );
    await settle(t);

    // While the page opens (the polaroid would be flying above it): still
    // invisible near the end, too – it would lie under the polaroid.
    await t.tap(find.text('open'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 270));
    expect(opacity(t), 0);

    // Page open: the record rolls in, from the right, turning as it goes.
    await t.pump(const Duration(milliseconds: 280));
    await t.pump(); // starts after the frame in which the page settled
    await t.pump(const Duration(milliseconds: 200));
    expect(opacity(t), inExclusiveRange(0, 1));
    await t.pump(const Duration(seconds: 1));
    expect(opacity(t), 1);

    // Fully there: it takes taps.
    await t.tap(find.byType(VinylRecord));
    await t.pump();
    expect(music.calls, ['play ${_candidate.uri}']);

    // Back: the page stays while the record rolls out, then closes.
    final navigator = t.state<NavigatorState>(find.byType(Navigator));
    unawaited(navigator.maybePop());
    await t.pump();
    await t.pump(const Duration(milliseconds: 120));
    expect(find.text(_pageText), findsOneWidget);
    expect(opacity(t), lessThan(1));
    await t.pump(const Duration(milliseconds: 200));
    await t.pump(const Duration(seconds: 1));
    expect(find.text(_pageText), findsNothing);

    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 1));
  });
}
