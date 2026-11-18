import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/app/app_locale.dart';
import 'package:randnotiz/app/providers.dart';
import 'package:randnotiz/core/database/app_database.dart';
import 'package:randnotiz/core/l10n/app_language.dart';
import 'package:randnotiz/core/theme/app_theme.dart';
import 'package:randnotiz/core/theme/season.dart';
import 'package:randnotiz/features/backup/data/drive_backup_service.dart';
import 'package:randnotiz/features/backup/domain/backup_service.dart';
import 'package:randnotiz/features/settings/data/settings_repository.dart';
import 'package:randnotiz/features/settings/presentation/settings_screen.dart';
import 'package:randnotiz/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../backup/fake_backup_service.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  const expected = {
    AppLanguage.de: 'randnotiz.info/de/datenschutz',
    AppLanguage.en: 'randnotiz.info/en/privacy',
    AppLanguage.fr: 'randnotiz.info/fr/confidentialite',
    AppLanguage.es: 'randnotiz.info/es/privacidad',
  };

  for (final MapEntry(key: language, value: label) in expected.entries) {
    testWidgets('settings in ${language.name}: the privacy policy in '
        '${language.name}', (tester) async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      final prefs = await SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(
          allowList: {
            ...SettingsRepository.keys,
            ...DriveBackupService.preferenceKeys,
          },
        ),
      );
      await prefs.setString(SettingsRepository.languageKey, language.name);
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            preferencesProvider.overrideWithValue(prefs),
            backupServiceProvider.overrideWithValue(
              FakeBackupService(
                const BackupStatus(phase: BackupPhase.signedOut),
              ),
            ),
          ],
          child: Consumer(
            builder: (context, ref, _) => MaterialApp(
              theme: AppTheme.build(Brightness.light, Season.autumn),
              locale: ref.watch(appLocaleProvider),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const SettingsScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text(label), 300);
      expect(find.text(label), findsOneWidget);
      for (final other in expected.values.where((l) => l != label)) {
        expect(find.text(other), findsNothing);
      }
    });
  }
}
