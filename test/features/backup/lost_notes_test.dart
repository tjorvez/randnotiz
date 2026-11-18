import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/app/database_unavailable_app.dart';
import 'package:randnotiz/app/providers.dart';
import 'package:randnotiz/core/database/app_database.dart';
import 'package:randnotiz/features/backup/domain/backup_service.dart';
import 'package:randnotiz/features/backup/presentation/backup_controller.dart';
import 'package:randnotiz/features/backup/presentation/lost_notes_prompt.dart';
import 'package:randnotiz/features/library/data/import_cleanup.dart';
import 'package:randnotiz/features/library/data/imported_photo_store.dart';
import 'package:randnotiz/features/notes/data/drift_note_repository.dart';
import 'package:randnotiz/features/notes/data/thumbnail_store.dart';
import 'package:randnotiz/features/notes/domain/note.dart';
import 'package:randnotiz/features/settings/data/settings_repository.dart';
import 'package:randnotiz/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../library/imported_photo_store_test.dart' show FakePicker;
import 'fake_backup_service.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SharedPreferencesWithCache prefs;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: {LostNotesController.preferenceKey},
      ),
    );
  });

  bool pending() => prefs.getBool(LostNotesController.preferenceKey) ?? false;

  group('the notice', () {
    late int restores;

    setUp(() => restores = 0);

    Future<void> start(WidgetTester t, {bool covered = false}) async {
      final navigator = GlobalKey<NavigatorState>();
      await t.pumpWidget(const SizedBox()); // a fresh process
      await t.pumpWidget(
        ProviderScope(
          overrides: [preferencesProvider.overrideWithValue(prefs)],
          child: MaterialApp(
            navigatorKey: navigator,
            locale: const Locale('de'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => LostNotesPrompt(
              covered: covered,
              navigatorKey: navigator,
              onRestore: () => restores++,
              child: child!,
            ),
            home: const Scaffold(body: Text('Tagebuch')),
          ),
        ),
      );
      await t.pumpAndSettle();
    }

    const title = 'Deine Notizen ließen sich nicht öffnen';

    testWidgets('nothing to tell normally', (t) async {
      await start(t);
      expect(find.text(title), findsNothing);
    });

    testWidgets('not over the lock or the introduction', (t) async {
      await prefs.setBool(LostNotesController.preferenceKey, true);
      await start(t, covered: true);
      expect(find.text(title), findsNothing);
    });

    testWidgets('"Nicht jetzt" asks again at the next start', (t) async {
      await prefs.setBool(LostNotesController.preferenceKey, true);
      await start(t);
      expect(find.text(title), findsOneWidget);
      expect(
        find.textContaining('behält Randnotiz alle deine Fotos'),
        findsOneWidget,
      );
      await t.tap(find.text('Nicht jetzt'));
      await t.pumpAndSettle();
      expect(find.text(title), findsNothing);
      expect(pending(), isTrue);

      await start(t);
      expect(find.text(title), findsOneWidget);
    });

    testWidgets('"Sicherung wiederherstellen" opens the backup; the pause '
        'lasts until the restore', (t) async {
      await prefs.setBool(LostNotesController.preferenceKey, true);
      await start(t);
      await t.tap(find.text('Sicherung wiederherstellen'));
      await t.pumpAndSettle();
      expect(restores, 1);
      expect(pending(), isTrue);
    });

    testWidgets('"Ohne weitermachen" ends it', (t) async {
      await prefs.setBool(LostNotesController.preferenceKey, true);
      await start(t);
      await t.tap(find.text('Ohne weitermachen'));
      await t.pumpAndSettle();
      expect(pending(), isFalse);
      expect(restores, 0);

      await start(t);
      expect(find.text(title), findsNothing);
    });

    testWidgets('fits with twice the text size on a small phone', (t) async {
      t.view.physicalSize = const Size(360, 640);
      t.view.devicePixelRatio = 1;
      t.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(t.view.reset);
      addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
      await prefs.setBool(LostNotesController.preferenceKey, true);
      await start(t);
      expect(t.takeException(), isNull);
      expect(find.text('Sicherung wiederherstellen'), findsOneWidget);
    });
  });

  testWidgets('notes unavailable right now: says so in the app language and '
      'tries again', (t) async {
    final settingsPrefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: SettingsRepository.keys,
      ),
    );
    await settingsPrefs.setString(SettingsRepository.languageKey, 'fr');
    var tries = 0;
    await t.pumpWidget(
      DatabaseUnavailableApp(
        prefs: settingsPrefs,
        onRetry: () async => tries++,
      ),
    );
    await t.pumpAndSettle();
    expect(
      find.text('Impossible d’ouvrir tes notes pour le moment'),
      findsOneWidget,
    );
    await t.tap(find.text('Réessayer'));
    await t.pumpAndSettle();
    expect(tries, 1);
  });

  group('automatic backups', () {
    Future<FakeBackupService> autoBackup({required bool lost}) async {
      if (lost) await prefs.setBool(LostNotesController.preferenceKey, true);
      final service = FakeBackupService(
        const BackupStatus(phase: BackupPhase.ready),
      );
      final container = ProviderContainer(
        overrides: [
          preferencesProvider.overrideWithValue(prefs),
          backupServiceProvider.overrideWithValue(service),
        ],
      );
      addTearDown(container.dispose);
      await container.read(backupStatusProvider.notifier).autoBackup();
      return service;
    }

    test('run normally', () async {
      expect((await autoBackup(lost: false)).calls, contains('backupNow'));
    });

    test('pause while lost notes await a restore', () async {
      expect((await autoBackup(lost: true)).calls, isEmpty);
    });
  });

  group('the start-up clean-up', () {
    late Directory dir;
    late AppDatabase db;
    late ImportedPhotoStore imports;
    late String orphan;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('randnotiz_cleanup');
      db = AppDatabase(NativeDatabase.memory());
      imports = ImportedPhotoStore(Directory('${dir.path}/imported'));
      const r = (width: 1, height: 1, takenAt: null);
      // A photo whose note is in the (lost) database, not in this one.
      orphan = (await imports.pickAndImport(FakePicker(r)))!.id;
    });

    tearDown(() async {
      await db.close();
      await dir.delete(recursive: true);
    });

    ImportCleanup cleanup({required bool paused}) => ImportCleanup(
      notes: DriftNoteRepository(db),
      imports: imports,
      thumbnails: ThumbnailStore(Directory('${dir.path}/thumbnails')),
      paused: () => paused,
    );

    test('keeps every photo while lost notes await a restore', () async {
      await cleanup(paused: true).run();
      expect(await imports.imageFile(orphan).exists(), isTrue);
    });

    test('otherwise removes photos without a note, keeps noted ones', () async {
      const r = (width: 1, height: 1, takenAt: null);
      final noted = (await imports.pickAndImport(FakePicker(r)))!.id;
      await DriftNoteRepository(db)
          .save(NoteDraft(assetId: noted, body: 'Da', date: DateTime(2026)));

      await cleanup(paused: false).run();
      expect(await imports.imageFile(orphan).exists(), isFalse);
      expect(await imports.imageFile(noted).exists(), isTrue);
    });
  });
}
