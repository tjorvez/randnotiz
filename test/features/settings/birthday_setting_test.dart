import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/app/providers.dart';
import 'package:randnotiz/core/format/formatters.dart';
import 'package:randnotiz/features/backup/domain/backup_service.dart';
import 'package:randnotiz/features/settings/data/settings_repository.dart';
import 'package:randnotiz/features/settings/presentation/settings_controller.dart';
import 'package:randnotiz/features/settings/presentation/settings_screen.dart';
import 'package:randnotiz/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../backup/fake_backup_service.dart';

void main() {
  late SharedPreferencesWithCache prefs;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: SettingsRepository.keys,
      ),
    );
  });

  test('no birthday by default', () {
    expect(SettingsRepository(prefs).load().birthday, isNull);
  });

  test('a birthday is saved as a calendar day and removed again', () async {
    final repo = SettingsRepository(prefs);
    await repo.save(repo.load().copyWith(birthday: DateTime(1990, 5, 7)));
    expect(prefs.getString(SettingsRepository.birthdayKey), '1990-05-07');
    expect(repo.load().birthday, DateTime(1990, 5, 7));

    await repo.save(repo.load().copyWith(clearBirthday: true));
    expect(prefs.containsKey(SettingsRepository.birthdayKey), isFalse);
    expect(repo.load().birthday, isNull);
  });

  test('other settings keep the birthday', () async {
    final repo = SettingsRepository(prefs);
    await repo.save(repo.load().copyWith(birthday: DateTime(1990, 5, 7)));
    await repo.save(repo.load().copyWith(widgetShowsText: true));
    expect(repo.load().birthday, DateTime(1990, 5, 7));
  });

  test('a damaged value counts as no birthday', () async {
    await prefs.setString(SettingsRepository.birthdayKey, 'gestern');
    expect(SettingsRepository(prefs).load().birthday, isNull);
  });

  testWidgets('the settings show, pick and remove the birthday', (t) async {
    Fmt.locale = 'de';
    addTearDown(() => Fmt.locale = 'en');
    final container = ProviderContainer(
      overrides: [
        preferencesProvider.overrideWithValue(prefs),
        backupServiceProvider.overrideWithValue(
          FakeBackupService(const BackupStatus(phase: BackupPhase.signedOut)),
        ),
        clockProvider.overrideWithValue(() => DateTime(2026, 11, 13, 9)),
      ],
    );
    addTearDown(container.dispose);
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('de'),
          home: SettingsScreen(),
        ),
      ),
    );
    await t.pump();

    final tile = find.text('Geburtstag');
    await t.scrollUntilVisible(tile, 200);
    expect(find.textContaining('Bleibt auf dem Gerät'), findsOneWidget);
    expect(find.byTooltip('Geburtstag entfernen'), findsNothing);

    // Picking: the dialog opens on the years; type the date instead.
    await t.tap(tile);
    await t.pumpAndSettle();
    await t.tap(find.byIcon(Icons.edit_outlined));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), '07.05.1990');
    await t.tap(find.text('OK'));
    await t.pumpAndSettle();

    expect(container.read(birthdayProvider), DateTime(1990, 5, 7));
    expect(find.text('7. Mai 1990'), findsOneWidget);

    await t.tap(find.byTooltip('Geburtstag entfernen'));
    await t.pump();
    expect(container.read(birthdayProvider), isNull);
    expect(prefs.containsKey(SettingsRepository.birthdayKey), isFalse);
  });
}
