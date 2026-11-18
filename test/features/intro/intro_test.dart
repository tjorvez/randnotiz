import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:randnotiz/app/app_locale.dart';
import 'package:randnotiz/app/providers.dart';
import 'package:randnotiz/app/router.dart';
import 'package:randnotiz/app/start_gate.dart';
import 'package:randnotiz/core/database/app_database.dart';
import 'package:randnotiz/core/l10n/app_language.dart';
import 'package:randnotiz/core/theme/app_theme.dart';
import 'package:randnotiz/core/theme/season.dart';
import 'package:randnotiz/features/backup/data/drive_backup_service.dart';
import 'package:randnotiz/features/backup/domain/backup_service.dart';
import 'package:randnotiz/features/backup/presentation/lost_notes_prompt.dart';
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

const welcomeTitle = 'Willkommen bei Randnotiz';
const cloudTitle = 'Dein Tagebuch bleibt deins.';
const firstTourTitle = 'Ein Foto, eine Geschichte.';
const lastTourTitle = 'Deine Momente kommen zurück.';
const claim =
    'Schreib deine eigene Geschichte – statt nur durch fremde zu swipen.';
const journalText = 'Tagebuch (Test)';
const lockTitle = 'Randnotiz ist gesperrt';

/// The app shell without photos, map & co.: the real start gate, the real
/// settings routes (settings, backup, introduction) and stand-ins for the
/// tabs.
GoRouter testRouter() => GoRouter(
  initialLocation: '/journal',
  routes: [
    GoRoute(
      path: '/journal',
      builder: (context, _) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => context.push('/settings'),
            child: const Text(journalText),
          ),
        ),
      ),
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
            LostNotesController.preferenceKey,
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
  /// [language] is set before the start (null: untouched – the test device
  /// speaks English).
  Future<SharedPreferencesWithCache> start(
    WidgetTester tester, {
    ThemeMode themeMode = ThemeMode.light,
    bool reduceMotion = false,
    AppLanguage? language = AppLanguage.de,
  }) async {
    final prefs = await openPrefs();
    if (language != null) {
      await prefs.setString(SettingsRepository.languageKey, language.name);
    }
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
            locale: ref.watch(appLocaleProvider),
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

  Future<void> tap(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  /// From the welcome page: the backup page, [choice] there, then through
  /// the tour to its last page.
  Future<void> throughTour(WidgetTester tester, String choice) async {
    await tap(tester, 'Weiter');
    expect(find.text(cloudTitle), findsOneWidget);
    await tap(tester, choice);
    expect(find.text(firstTourTitle), findsOneWidget);
    for (var i = 0; i < 3; i++) {
      await tap(tester, 'Weiter');
    }
    expect(find.text(lastTourTitle), findsOneWidget);
  }

  bool? seen(SharedPreferencesWithCache prefs) =>
      prefs.getBool(IntroController.preferenceKey);

  testWidgets('first start with an empty diary: intro covers app and lock', (
    tester,
  ) async {
    final prefs = await start(tester);
    expect(find.text(welcomeTitle), findsOneWidget);
    expect(find.text(claim), findsOneWidget, reason: 'the claim greets');
    expect(find.text(journalText), findsNothing, reason: 'app hidden');
    expect(find.text(lockTitle), findsNothing);
    expect(auth.calls, 0, reason: 'no biometric prompt behind the intro');
    expect(seen(prefs), isNull, reason: 'not finished yet');
  });

  testWidgets('existing notes: no intro, flag set silently', (tester) async {
    await addNote();
    final prefs = await start(tester);
    expect(find.text(welcomeTitle), findsNothing);
    expect(find.text(journalText), findsOneWidget);
    expect(seen(prefs), isTrue);

    // Even if the diary is emptied later, the intro stays away.
    await db.delete(db.notes).go();
    await start(tester);
    expect(find.text(welcomeTitle), findsNothing);
  });

  testWidgets('the device language comes first; a tap switches the app', (
    tester,
  ) async {
    final prefs = await start(tester, language: null);
    // The test device speaks English.
    expect(find.text('Welcome to Randnotiz'), findsOneWidget);
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'English'))
          .selected,
      isTrue,
    );
    expect(prefs.getString(SettingsRepository.languageKey), isNull);

    await tap(tester, 'Français');
    expect(find.text('Bienvenue dans Randnotiz'), findsOneWidget);
    expect(
      find.text(
        'Écris ta propre histoire – au lieu de faire défiler celles des '
        'autres.',
      ),
      findsOneWidget,
    );
    expect(prefs.getString(SettingsRepository.languageKey), 'fr');

    await tap(tester, 'Español');
    expect(find.text('Te damos la bienvenida a Randnotiz'), findsOneWidget);
    await tap(tester, 'Deutsch');
    expect(find.text(welcomeTitle), findsOneWidget);
    expect(find.text(claim), findsOneWidget);
    expect(prefs.getString(SettingsRepository.languageKey), 'de');
  });

  testWidgets('skip on the first page, the flag survives a restart', (
    tester,
  ) async {
    final prefs = await start(tester);
    await tap(tester, 'Überspringen');
    expect(find.text(welcomeTitle), findsNothing);
    expect(find.text(journalText), findsOneWidget);
    expect(seen(prefs), isTrue);

    final again = await start(tester);
    expect(seen(again), isTrue);
    expect(find.text(welcomeTitle), findsNothing);
    expect(find.text(journalText), findsOneWidget);
  });

  testWidgets('swipe and "Weiter" move through six pages', (tester) async {
    await start(tester);
    expect(
      find.bySemanticsLabel('Seite 1 von 6'),
      findsOneWidget,
      reason: 'page indicator for TalkBack',
    );
    await tester.fling(find.text(welcomeTitle), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text(cloudTitle), findsOneWidget);
    expect(find.bySemanticsLabel('Seite 2 von 6'), findsOneWidget);
    expect(
      find.text('Weiter'),
      findsNothing,
      reason: 'the backup question is answered with its buttons',
    );
    expect(find.text('Sicherung einrichten'), findsOneWidget);

    await tap(tester, 'Ohne Sicherung weiter');
    expect(find.text(firstTourTitle), findsOneWidget);
    expect(find.bySemanticsLabel('Seite 3 von 6'), findsOneWidget);
    for (final title in [
      'Schreib auf, wie es war.',
      'Seite für Seite dein Tagebuch.',
      lastTourTitle,
    ]) {
      await tap(tester, 'Weiter');
      expect(find.text(title), findsOneWidget);
    }
    expect(find.bySemanticsLabel('Seite 6 von 6'), findsOneWidget);
    expect(find.text('Weiter'), findsNothing, reason: 'last page');
    expect(find.text('Los geht’s'), findsOneWidget);
    expect(find.text(claim), findsOneWidget, reason: 'the claim says goodbye');
  });

  testWidgets('without backup: "Los geht’s" leads to the journal – and the '
      'lock still applies', (tester) async {
    auth = FakeAuthenticator(result: AuthResult.canceled);
    final prefs = await start(tester);
    await throughTour(tester, 'Ohne Sicherung weiter');
    await tap(tester, 'Los geht’s');
    expect(seen(prefs), isTrue);
    expect(find.text(lastTourTitle), findsNothing);
    // The intro did not unlock anything: the lock screen comes now.
    expect(find.text(lockTitle), findsOneWidget);
    expect(find.text(journalText), findsNothing);
    expect(auth.calls, 1);
  });

  testWidgets('without backup, lock off/unlocked: the journal', (tester) async {
    await start(tester);
    await throughTour(tester, 'Ohne Sicherung weiter');
    await tap(tester, 'Los geht’s');
    expect(find.text(journalText), findsOneWidget);
  });

  testWidgets('"Sicherung einrichten": first the tour, then the backup; '
      'back leads to the journal', (tester) async {
    final prefs = await start(tester);
    await throughTour(tester, 'Sicherung einrichten');
    expect(find.text('Los geht’s'), findsNothing);
    await tap(tester, 'Weiter zur Sicherung');
    expect(seen(prefs), isTrue);
    expect(find.text('Sicherung in Google Drive'), findsOneWidget);
    expect(find.text('Mit Google verbinden'), findsOneWidget);
    expect(find.textContaining('Du hast schon eine Sicherung?'), findsNothing);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text(journalText), findsOneWidget);
  });

  testWidgets('the backup choice survives "Überspringen" in the tour', (
    tester,
  ) async {
    await start(tester);
    await tap(tester, 'Weiter');
    await tap(tester, 'Sicherung einrichten');
    await tap(tester, 'Überspringen');
    expect(find.text('Mit Google verbinden'), findsOneWidget);
  });

  testWidgets('going back to the backup page shows the choice', (tester) async {
    await start(tester);
    await tap(tester, 'Weiter');
    await tap(tester, 'Ich habe schon eine Sicherung');
    await tester.fling(find.text(firstTourTitle), const Offset(400, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text(cloudTitle), findsOneWidget);
    expect(
      find.descendant(
        of: find.widgetWithText(
          OutlinedButton,
          'Ich habe schon eine Sicherung',
        ),
        matching: find.byIcon(Icons.check),
      ),
      findsOneWidget,
    );
  });

  testWidgets('"Ich habe schon eine Sicherung": tour, connect, unlock, '
      'restore, then the entries', (tester) async {
    backup = FakeBackupService(
      const BackupStatus(phase: BackupPhase.signedOut),
      connectsTo: BackupPhase.needsUnlock,
    );
    final prefs = await start(tester);
    await throughTour(tester, 'Ich habe schon eine Sicherung');
    await tap(tester, 'Weiter zur Wiederherstellung');
    expect(seen(prefs), isTrue);
    expect(
      find.textContaining('Du hast schon eine Sicherung?'),
      findsOneWidget,
    );

    await tap(tester, 'Mit Google verbinden');
    // The backup screen's own "backup found" state takes over.
    expect(find.textContaining('Du hast schon eine Sicherung?'), findsNothing);
    expect(find.text('Passwort oder Notfallschlüssel'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'richtiges Passwort');
    await tap(tester, 'Entsperren');
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
    await throughTour(tester, 'Ich habe schon eine Sicherung');
    await tap(tester, 'Weiter zur Wiederherstellung');
    await tap(tester, 'Mit Google verbinden');
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
    await tap(tester, journalText);
    await tester.scrollUntilVisible(find.text('Einführung ansehen'), 200);
    await tester.ensureVisible(find.text('Einführung ansehen'));
    await tester.pump();
    await tap(tester, 'Einführung ansehen');
    expect(find.text(welcomeTitle), findsOneWidget);

    // Skipping returns to the settings.
    await tap(tester, 'Überspringen');
    expect(find.text(welcomeTitle), findsNothing);
    expect(find.text('Einführung ansehen'), findsOneWidget);
    expect(seen(prefs), isTrue);

    // A backup action replaces the intro: back leads to the settings.
    await tap(tester, 'Einführung ansehen');
    await throughTour(tester, 'Sicherung einrichten');
    await tap(tester, 'Weiter zur Sicherung');
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
    await tap(tester, journalText);
    await tester.scrollUntilVisible(find.text('Einführung ansehen'), 200);
    await tester.ensureVisible(find.text('Einführung ansehen'));
    await tester.pump();
    await tap(tester, 'Einführung ansehen');
    await tap(tester, 'Überspringen');
    expect(seen(prefs), isNull);
  });

  testWidgets('without a backup in the build: one way on', (tester) async {
    backup = FakeBackupService(BackupStatus.off);
    await start(tester);
    await tap(tester, 'Weiter');
    expect(find.text('Sicherung einrichten'), findsNothing);
    expect(find.text('Ich habe schon eine Sicherung'), findsNothing);
    expect(
      find.text(
        'In dieser Version ist die Sicherung nicht verfügbar.',
        skipOffstage: false,
      ),
      findsOneWidget,
    );
    await throughTourFrom(tester, 'Weiter');
    await tap(tester, 'Los geht’s');
    expect(find.text(journalText), findsOneWidget);
  });

  testWidgets('"reduce motion": "Weiter" jumps without animation', (
    tester,
  ) async {
    await start(tester, reduceMotion: true);
    await tester.tap(find.text('Weiter'));
    await tester.pump();
    // Already in place after a single frame: no slide.
    final title = find.text(cloudTitle);
    expect(title, findsOneWidget);
    expect(tester.getTopLeft(title).dx, closeTo(28, 0.5));
    expect(find.text(welcomeTitle), findsNothing);
  });

  for (final language in AppLanguage.translated) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('${language.name}, ${mode.name}, twice the font size, '
          'small phone: no overflow on any page', (tester) async {
        tester.view.physicalSize = const Size(1080, 1920);
        tester.view.devicePixelRatio = 3; // 360 × 640 dp
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await start(tester, themeMode: mode, language: language);
        final l10n = lookupAppLocalizations(Locale(language.name));
        expect(tester.takeException(), isNull);
        await tap(tester, l10n.introNext);
        expect(tester.takeException(), isNull);
        await tap(tester, l10n.introSetUpBackup);
        for (var i = 0; i < 3; i++) {
          expect(tester.takeException(), isNull);
          await tap(tester, l10n.introNext);
        }
        expect(tester.takeException(), isNull);
        // The way on stays in reach below the scrolling text.
        await tap(tester, l10n.introStartBackup);
        expect(find.text(l10n.backupTitle), findsOneWidget);
      });
    }
  }
}

/// From a page with "Weiter" ([next]) to the last page of the tour.
Future<void> throughTourFrom(WidgetTester tester, String next) async {
  for (var i = 0; i < 4; i++) {
    await tester.tap(find.text(next));
    await tester.pumpAndSettle();
  }
  expect(find.text(lastTourTitle), findsOneWidget);
}
