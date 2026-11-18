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
import 'package:randnotiz/core/platform/app_info.dart';
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
import 'package:randnotiz/features/settings/data/settings_repository.dart';
import 'package:randnotiz/features/whats_new/domain/release_notes.dart';
import 'package:randnotiz/features/whats_new/presentation/whats_new_controller.dart';
import 'package:randnotiz/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../backup/fake_backup_service.dart';

class _Authenticator implements Authenticator {
  AuthResult result = AuthResult.success;
  int calls = 0;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<AuthResult> authenticate({required String reason}) async {
    calls++;
    return result;
  }
}

const dialogTitle = 'Neu in Randnotiz 1.2';
const done = 'Alles klar';
const journalText = 'Tagebuch (Test)';
const welcomeTitle = 'Willkommen bei Randnotiz';
const lockTitle = 'Randnotiz ist gesperrt';

void main() {
  group('AppVersion', () {
    test('parses version names, ignoring suffixes', () {
      expect(AppVersion.tryParse('1.2.0'), const AppVersion(1, 2));
      expect(AppVersion.tryParse('1.2.3-dev'), const AppVersion(1, 2, 3));
      expect(AppVersion.tryParse('2'), const AppVersion(2, 0));
      expect(AppVersion.tryParse('1.10+7'), const AppVersion(1, 10));
      expect(AppVersion.tryParse(null), isNull);
      expect(AppVersion.tryParse(''), isNull);
      expect(AppVersion.tryParse('dev'), isNull);
    });

    test('compares part by part, not as text', () {
      expect(const AppVersion(1, 10) > const AppVersion(1, 9), isTrue);
      expect(const AppVersion(2, 0) > const AppVersion(1, 99, 99), isTrue);
      expect(const AppVersion(1, 2, 1) > const AppVersion(1, 2), isTrue);
      expect(const AppVersion(1, 2) <= const AppVersion(1, 2), isTrue);
    });

    test('label leaves out a zero patch', () {
      expect(const AppVersion(1, 2).label, '1.2');
      expect(const AppVersion(1, 2, 1).label, '1.2.1');
    });
  });

  group('notesSince', () {
    ReleaseNotes notes(int minor) =>
        ReleaseNotes(version: AppVersion(1, minor), items: const []);
    final all = [notes(2), notes(4), notes(3)];
    List<int> minors(List<ReleaseNotes> list) => [
      for (final n in list) n.version.minor,
    ];

    test('every release after the seen one up to the current, newest '
        'first', () {
      expect(
        minors(
          notesSince(const AppVersion(1, 2), const AppVersion(1, 4), from: all),
        ),
        [4, 3],
      );
    });

    test('nothing seen: everything since the version before the dialog', () {
      expect(minors(notesSince(null, const AppVersion(1, 3), from: all)), [
        3,
        2,
      ]);
    });

    test('nothing for the same or an older version, or a release without '
        'notes', () {
      expect(
        notesSince(const AppVersion(1, 4), const AppVersion(1, 4), from: all),
        isEmpty,
      );
      expect(
        notesSince(const AppVersion(1, 4), const AppVersion(1, 3), from: all),
        isEmpty,
      );
      expect(
        notesSince(
          const AppVersion(1, 4),
          const AppVersion(1, 4, 1),
          from: all,
        ),
        isEmpty,
      );
    });

    test('the shipped notes: 1.2 has its texts in every language', () async {
      final latest = notesSince(null, const AppVersion(1, 2));
      expect(latest.single.version, const AppVersion(1, 2));
      for (final language in AppLanguage.translated) {
        final l10n = await AppLocalizations.delegate.load(
          Locale(language.name),
        );
        for (final item in latest.single.items) {
          expect(item.title(l10n), isNotEmpty);
          expect(item.body(l10n), isNotEmpty);
        }
      }
    });

    test('the shipped notes: 1.3 tells about encryption and the share of '
        'life, in every language', () async {
      final latest = notesSince(
        const AppVersion(1, 2, 1),
        const AppVersion(1, 3),
      );
      expect(latest.single.version, const AppVersion(1, 3));
      expect(latest.single.items, hasLength(2));
      for (final language in AppLanguage.translated) {
        final l10n = await AppLocalizations.delegate.load(
          Locale(language.name),
        );
        for (final item in latest.single.items) {
          expect(item.title(l10n), isNotEmpty);
          expect(item.body(l10n), isNotEmpty);
        }
      }
    });
  });

  group('the dialog at start', () {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

    late AppDatabase db;
    late _Authenticator auth;
    late SharedPreferencesWithCache prefs;

    setUp(() async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      db = AppDatabase(NativeDatabase.memory());
      auth = _Authenticator();
      prefs = await SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(
          allowList: {
            ...SettingsRepository.keys,
            GeoBackfillController.preferenceKey,
            RecentSearches.preferenceKey,
            MapPreferences.bordersKey,
            ...DriveBackupService.preferenceKeys,
            LostNotesController.preferenceKey,
            IntroController.preferenceKey,
            WhatsNewController.preferenceKey,
          },
        ),
      );
      await prefs.setString(SettingsRepository.languageKey, 'de');
    });

    tearDown(() => db.close());

    String? seenVersion() => prefs.getString(WhatsNewController.preferenceKey);

    /// An installation that has been used before (the introduction is
    /// behind it).
    Future<void> existingInstall() =>
        prefs.setBool(IntroController.preferenceKey, true);

    /// A fresh process of the app in [version] ([version] null: the
    /// platform cannot tell).
    Future<void> start(
      WidgetTester tester, {
      String? version = '1.2.0',
      ThemeMode themeMode = ThemeMode.light,
      double textScale = 1,
    }) async {
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            preferencesProvider.overrideWithValue(prefs),
            authenticatorProvider.overrideWithValue(auth),
            backupServiceProvider.overrideWithValue(
              FakeBackupService(
                const BackupStatus(phase: BackupPhase.signedOut),
              ),
            ),
            appVersionProvider.overrideWith((ref) async => version),
            routerProvider.overrideWith((ref) {
              final router = GoRouter(
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
              ref.onDispose(router.dispose);
              return router;
            }),
            clockProvider.overrideWithValue(() => DateTime(2026, 11, 8)),
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
                    .copyWith(textScaler: TextScaler.linear(textScale)),
                child: StartGate(child: child!),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('update from a version before the dialog: shown once', (
      tester,
    ) async {
      await existingInstall();
      await start(tester);
      expect(find.text(dialogTitle), findsOneWidget);
      expect(find.text('Kalender'), findsOneWidget);
      expect(find.text('Sammlungen'), findsOneWidget);
      expect(seenVersion(), isNull, reason: 'only once it is closed');

      await tester.tap(find.text(done));
      await tester.pumpAndSettle();
      expect(find.text(dialogTitle), findsNothing);
      expect(find.text(journalText), findsOneWidget);
      expect(seenVersion(), '1.2.0');

      await start(tester);
      expect(find.text(dialogTitle), findsNothing);
    });

    testWidgets('Back closes it, and it counts as seen', (tester) async {
      await existingInstall();
      await start(tester);
      expect(find.text(dialogTitle), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text(dialogTitle), findsNothing);
      expect(seenVersion(), '1.2.0');
    });

    testWidgets('closed without a decision (app killed): shown again', (
      tester,
    ) async {
      await existingInstall();
      await start(tester);
      expect(find.text(dialogTitle), findsOneWidget);
      await start(tester);
      expect(find.text(dialogTitle), findsOneWidget);
    });

    testWidgets('fresh installation: the introduction, no dialog – not '
        'even after it', (tester) async {
      await start(tester);
      expect(find.text(welcomeTitle), findsOneWidget);
      expect(find.text(dialogTitle), findsNothing);
      expect(seenVersion(), '1.2.0', reason: 'recorded right away');

      await tester.tap(find.text('Überspringen'));
      await tester.pumpAndSettle();
      expect(find.text(journalText), findsOneWidget);
      expect(find.text(dialogTitle), findsNothing);

      await start(tester);
      expect(find.text(dialogTitle), findsNothing);
    });

    testWidgets('the next update with notes is shown, a later one without '
        'notes is not', (tester) async {
      await existingInstall();
      await prefs.setString(WhatsNewController.preferenceKey, '1.1.0');
      await start(tester);
      expect(find.text(dialogTitle), findsOneWidget);
      await tester.tap(find.text(done));
      await tester.pumpAndSettle();

      await start(tester, version: '1.2.1');
      expect(find.text(dialogTitle), findsNothing);
      expect(seenVersion(), '1.2.0');
    });

    testWidgets('version unknown: nothing', (tester) async {
      await existingInstall();
      await start(tester, version: null);
      expect(find.text(journalText), findsOneWidget);
      expect(find.text(dialogTitle), findsNothing);
    });

    testWidgets('waits for unlocking – never over the lock screen', (
      tester,
    ) async {
      await existingInstall();
      auth.result = AuthResult.canceled;
      await start(tester);
      expect(find.text(lockTitle), findsOneWidget);
      expect(
        find.text(dialogTitle, skipOffstage: false),
        findsNothing,
        reason:
            'not even hidden behind the lock, so it appears with its '
            'entrance when the app is unlocked',
      );

      auth.result = AuthResult.success;
      await tester.tap(find.text('Entsperren'));
      await tester.pumpAndSettle();
      expect(find.text(lockTitle), findsNothing);
      expect(find.text(dialogTitle), findsOneWidget);
    });

    testWidgets('lost notes come first; the news waits for the decision', (
      tester,
    ) async {
      await existingInstall();
      await prefs.setBool(LostNotesController.preferenceKey, true);
      await start(tester);
      expect(
        find.text('Deine Notizen ließen sich nicht öffnen'),
        findsOneWidget,
      );
      expect(find.text(dialogTitle), findsNothing);

      await tester.tap(find.text('Ohne weitermachen'));
      await tester.pumpAndSettle();
      expect(find.text(dialogTitle), findsOneWidget);
    });

    testWidgets('again from the settings, without touching the record', (
      tester,
    ) async {
      await existingInstall();
      await prefs.setString(WhatsNewController.preferenceKey, '1.2.0');
      await start(tester);
      await tester.tap(find.text(journalText));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Neuigkeiten'), 200);
      await tester.tap(find.text('Neuigkeiten'));
      await tester.pumpAndSettle();
      // Every release, headed by the newest.
      const newest = 'Neu in Randnotiz 1.3';
      expect(find.text(newest), findsOneWidget);
      await tester.tap(find.text(done));
      await tester.pumpAndSettle();
      expect(find.text(newest), findsNothing);
      expect(seenVersion(), '1.2.0');
    });

    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('${mode.name}, 2× text on a small phone: fits and '
          'scrolls', (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await existingInstall();
        await start(tester, themeMode: mode, textScale: 2);
        expect(tester.takeException(), isNull);
        expect(find.text(dialogTitle), findsOneWidget);
        await tester.ensureVisible(find.text(done));
        await tester.tap(find.text(done));
        await tester.pumpAndSettle();
        expect(find.text(dialogTitle), findsNothing);
      });
    }
  });
}
