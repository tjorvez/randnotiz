import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:randnotiz/app/providers.dart';
import 'package:randnotiz/app/router.dart';
import 'package:randnotiz/app/start_gate.dart';
import 'package:randnotiz/core/database/app_database.dart';
import 'package:randnotiz/core/theme/app_theme.dart';
import 'package:randnotiz/core/theme/season.dart';
import 'package:randnotiz/features/backup/data/drive_backup_service.dart';
import 'package:randnotiz/features/backup/domain/backup_service.dart';
import 'package:randnotiz/features/geo/presentation/geo_backfill_controller.dart';
import 'package:randnotiz/features/intro/presentation/intro_controller.dart';
import 'package:randnotiz/features/journal/data/recent_searches.dart';
import 'package:randnotiz/features/lock/domain/authenticator.dart';
import 'package:randnotiz/features/map/presentation/map_preferences.dart';
import 'package:randnotiz/features/notes/data/drift_note_repository.dart';
import 'package:randnotiz/features/notes/domain/note.dart';
import 'package:randnotiz/features/settings/data/settings_repository.dart';
import 'package:randnotiz/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../backup/fake_backup_service.dart';

class FakeAuthenticator implements Authenticator {
  FakeAuthenticator({this.result = AuthResult.success});

  final AuthResult result;
  int calls = 0;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<AuthResult> authenticate({required String reason}) async {
    calls++;
    return result;
  }
}

const introTitle = 'Deine Gedanken gehören nur dir.';
const libraryText = 'Bibliothek (Test)';
const journalText = 'Tagebuch (Test)';
const lockTitle = 'Randnotiz ist gesperrt';

/// The app shell without photos, map & co.: the real start gate, the real
/// settings routes (settings, backup, introduction) and stand-ins for the
/// tabs.
GoRouter testRouter() => GoRouter(
  initialLocation: '/library',
  routes: [
    GoRoute(
      path: '/library',
      builder: (context, _) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => context.push('/settings'),
            child: const Text(libraryText),
          ),
        ),
      ),
    ),
    GoRoute(
      path: '/journal',
      builder: (_, _) => const Scaffold(body: Center(child: Text(journalText))),
    ),
    settingsRoute(),
  ],
);

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late FakeAuthenticator auth;
  late FakeBackupService backup;

  Future<SharedPreferencesWithCache> openPrefs() =>
      SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(
          allowList: {
            ...SettingsRepository.keys,
            GeoBackfillController.preferenceKey,
            RecentSearches.preferenceKey,
            MapPreferences.bordersKey,
            ...DriveBackupService.preferenceKeys,
            IntroController.preferenceKey,
          },
        ),
      );

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    db = AppDatabase(NativeDatabase.memory());
    auth = FakeAuthenticator();
    backup = FakeBackupService(
      const BackupStatus(phase: BackupPhase.signedOut),
    );
  });

  tearDown(() => db.close());

  /// Starts the app ("a process start"); returns the preferences it uses.
  Future<SharedPreferencesWithCache> start(
    WidgetTester tester, {
    ThemeMode themeMode = ThemeMode.light,
    bool reduceMotion = false,
  }) async {
    final prefs = await openPrefs();
    // A fresh tree = a fresh process (new providers, new router).
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          preferencesProvider.overrideWithValue(prefs),
          authenticatorProvider.overrideWithValue(auth),
          backupServiceProvider.overrideWithValue(backup),
          routerProvider.overrideWith((ref) {
            final router = testRouter();
            ref.onDispose(router.dispose);
            return router;
          }),
          clockProvider.overrideWithValue(() => DateTime(2026, 11, 1)),
        ],
        child: Consumer(
          builder: (context, ref, _) => MaterialApp.router(
            theme: AppTheme.build(Brightness.light, Season.autumn),
            darkTheme: AppTheme.build(Brightness.dark, Season.autumn),
            themeMode: themeMode,
            locale: const Locale('de'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: ref.watch(routerProvider),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(disableAnimations: reduceMotion),
              child: StartGate(child: child!),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return prefs;
  }

  Future<void> addNote() => DriftNoteRepository(db).save(
    NoteDraft(assetId: 'a1', body: 'Ein Eintrag', date: DateTime(2026, 5, 1)),
  );

  Future<void> toLastPage(WidgetTester tester) async {
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('Weiter'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Eine Sicherung nur für dich.'), findsOneWidget);
  }

  Future<void> tapAction(WidgetTester tester, String label) async {
    await tester.scrollUntilVisible(
      find.text(label),
      100,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  bool? seen(SharedPreferencesWithCache prefs) =>
      prefs.getBool(IntroController.preferenceKey);

  testWidgets('first start with an empty diary: intro covers app and lock', (
    tester,
  ) async {
    final prefs = await start(tester);
    expect(find.text(introTitle), findsOneWidget);
    expect(find.text(libraryText), findsNothing, reason: 'app hidden');
    expect(find.text(lockTitle), findsNothing);
    expect(auth.calls, 0, reason: 'no biometric prompt behind the intro');
    expect(seen(prefs), isNull, reason: 'not finished yet');
  });

  testWidgets('existing notes: no intro, flag set silently', (tester) async {
    await addNote();
    final prefs = await start(tester);
    expect(find.text(introTitle), findsNothing);
    expect(find.text(libraryText), findsOneWidget);
    expect(seen(prefs), isTrue);

    // Even if the diary is emptied later, the intro stays away.
    await db.delete(db.notes).go();
    await start(tester);
    expect(find.text(introTitle), findsNothing);
  });

  testWidgets('skip on the first page, the flag survives a restart', (
    tester,
  ) async {
    final prefs = await start(tester);
    await tester.tap(find.text('Überspringen'));
    await tester.pumpAndSettle();
    expect(find.text(introTitle), findsNothing);
    expect(find.text(libraryText), findsOneWidget);
    expect(seen(prefs), isTrue);

    final again = await start(tester);
    expect(seen(again), isTrue);
    expect(find.text(introTitle), findsNothing);
    expect(find.text(libraryText), findsOneWidget);
  });

  testWidgets('swipe and "Weiter" move through three pages', (tester) async {
    await start(tester);
    expect(
      find.bySemanticsLabel('Seite 1 von 3'),
      findsOneWidget,
      reason: 'page indicator for TalkBack',
    );
    await tester.fling(find.text(introTitle), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Dein Tagebuch ist verschlossen.'), findsOneWidget);
    expect(find.bySemanticsLabel('Seite 2 von 3'), findsOneWidget);
    await tester.tap(find.text('Weiter'));
    await tester.pumpAndSettle();
    expect(find.text('Eine Sicherung nur für dich.'), findsOneWidget);
    expect(find.text('Weiter'), findsNothing, reason: 'last page');
    expect(find.text('Sicherung einrichten'), findsOneWidget);
  });

  testWidgets('"Später" leads to the library – and the lock still applies', (
    tester,
  ) async {
    auth = FakeAuthenticator(result: AuthResult.canceled);
    final prefs = await start(tester);
    await toLastPage(tester);
    await tapAction(tester, 'Später');
    expect(seen(prefs), isTrue);
    expect(find.text(introTitle), findsNothing);
    // The intro did not unlock anything: the lock screen comes now.
    expect(find.text(lockTitle), findsOneWidget);
    expect(find.text(libraryText), findsNothing);
    expect(auth.calls, 1);
  });

  testWidgets('"Später" with the lock off/unlocked shows the library', (
    tester,
  ) async {
    await start(tester);
    await toLastPage(tester);
    await tapAction(tester, 'Später');
    expect(find.text(libraryText), findsOneWidget);
  });

  testWidgets('"Sicherung einrichten" opens backup, back leads to library', (
    tester,
  ) async {
    final prefs = await start(tester);
    await toLastPage(tester);
    await tapAction(tester, 'Sicherung einrichten');
    expect(seen(prefs), isTrue);
    expect(find.text('Sicherung in Google Drive'), findsOneWidget);
    expect(find.text('Mit Google verbinden'), findsOneWidget);
    expect(find.textContaining('Du hast schon eine Sicherung?'), findsNothing);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text(libraryText), findsOneWidget);
  });

  testWidgets('"Ich habe schon eine Sicherung": connect, unlock, restore, '
      'then the entries', (tester) async {
    backup = FakeBackupService(
      const BackupStatus(phase: BackupPhase.signedOut),
      connectsTo: BackupPhase.needsUnlock,
    );
    final prefs = await start(tester);
    await toLastPage(tester);
    await tapAction(tester, 'Ich habe schon eine Sicherung');
    expect(seen(prefs), isTrue);
    expect(
      find.textContaining('Du hast schon eine Sicherung?'),
      findsOneWidget,
    );

    await tester.tap(find.text('Mit Google verbinden'));
    await tester.pumpAndSettle();
    // The backup screen's own "backup found" state takes over.
    expect(find.textContaining('Du hast schon eine Sicherung?'), findsNothing);
    expect(find.text('Passwort oder Notfallschlüssel'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'richtiges Passwort');
    await tester.tap(find.text('Entsperren'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Wiederherstellen'));
    await tester.pumpAndSettle();
    expect(
      backup.calls,
      containsAllInOrder([
        'connect',
        'unlock:richtiges '
            'Passwort',
        'restore',
      ]),
    );
    expect(find.text(journalText), findsOneWidget);
  });

  testWidgets('restore path, account without backup: says so', (tester) async {
    await start(tester);
    await toLastPage(tester);
    await tapAction(tester, 'Ich habe schon eine Sicherung');
    await tester.tap(find.text('Mit Google verbinden'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('In diesem Google-Konto liegt keine Sicherung'),
      findsOneWidget,
    );
    expect(find.text('Backup-Passwort festlegen'), findsOneWidget);
  });

  testWidgets('"Einführung ansehen" in the settings, flag unchanged', (
    tester,
  ) async {
    await addNote();
    final prefs = await start(tester);
    expect(seen(prefs), isTrue);
    await tester.tap(find.text(libraryText));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Einführung ansehen'), 200);
    await tester.tap(find.text('Einführung ansehen'));
    await tester.pumpAndSettle();
    expect(find.text(introTitle), findsOneWidget);

    // Skipping returns to the settings.
    await tester.tap(find.text('Überspringen'));
    await tester.pumpAndSettle();
    expect(find.text(introTitle), findsNothing);
    expect(find.text('Einführung ansehen'), findsOneWidget);
    expect(seen(prefs), isTrue);

    // A backup action replaces the intro: back leads to the settings.
    await tester.tap(find.text('Einführung ansehen'));
    await tester.pumpAndSettle();
    await toLastPage(tester);
    await tapAction(tester, 'Sicherung einrichten');
    expect(find.text('Mit Google verbinden'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Einführung ansehen'), findsOneWidget);
    expect(seen(prefs), isTrue);
  });

  testWidgets('replaying never marks a fresh install as seen', (tester) async {
    // Flag not set, but notes exist → set silently on start (see above);
    // here: the flag is cleared and the intro opened from the settings.
    await addNote();
    final prefs = await start(tester);
    await prefs.remove(IntroController.preferenceKey);
    await tester.tap(find.text(libraryText));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Einführung ansehen'), 200);
    await tester.tap(find.text('Einführung ansehen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Überspringen'));
    await tester.pumpAndSettle();
    expect(seen(prefs), isNull);
  });

  testWidgets('without a backup in the build: one way on', (tester) async {
    backup = FakeBackupService(BackupStatus.off);
    await start(tester);
    await toLastPage(tester);
    expect(find.text('Sicherung einrichten'), findsNothing);
    expect(find.text('Ich habe schon eine Sicherung'), findsNothing);
    await tapAction(tester, 'Los geht’s');
    expect(find.text(libraryText), findsOneWidget);
  });

  testWidgets('"reduce motion": "Weiter" jumps without animation', (
    tester,
  ) async {
    await start(tester, reduceMotion: true);
    await tester.tap(find.text('Weiter'));
    await tester.pump();
    // Already in place after a single frame: no slide.
    final title = find.text('Dein Tagebuch ist verschlossen.');
    expect(title, findsOneWidget);
    expect(tester.getTopLeft(title).dx, closeTo(28, 0.5));
    expect(find.text(introTitle), findsNothing);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('${mode.name}, twice the font size, small phone: no overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 3; // 360 × 640 dp
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await start(tester, themeMode: mode);
      expect(tester.takeException(), isNull);
      await toLastPage(tester);
      expect(tester.takeException(), isNull);
      // Everything on the last page can be reached by scrolling.
      await tapAction(tester, 'Später');
      expect(find.text(libraryText), findsOneWidget);
    });
  }
}
