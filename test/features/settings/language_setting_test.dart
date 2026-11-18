import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/core/l10n/app_language.dart';
import 'package:randnotiz/features/settings/data/settings_repository.dart';
import 'package:randnotiz/features/settings/data/system_language_sync.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// Android's per-app language as a field (null: before Android 13).
class FakeNativeLanguage implements NativeAppLanguage {
  FakeNativeLanguage(this.tag);

  String? tag;
  final writes = <String>[];

  @override
  Future<String?> read() async => tag;

  @override
  Future<void> write(String tag) async {
    writes.add(tag);
    this.tag = tag;
  }
}

void main() {
  late SharedPreferencesWithCache prefs;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: {
          ...SettingsRepository.keys,
          SystemLanguageSync.preferenceKey,
        },
      ),
    );
  });

  group('language setting', () {
    test('a new install follows the device', () async {
      final repo = SettingsRepository(prefs);
      await repo.keepGermanForEarlierInstalls(existingInstall: false);
      expect(repo.load().language, AppLanguage.system);
    });

    test('an install from the German-only time stays German', () async {
      final repo = SettingsRepository(prefs);
      await repo.keepGermanForEarlierInstalls(existingInstall: true);
      expect(repo.load().language, AppLanguage.de);
    });

    test('so does one whose settings were saved before', () async {
      await prefs.setString('themeMode', 'dark');
      final repo = SettingsRepository(prefs);
      await repo.keepGermanForEarlierInstalls(existingInstall: false);
      expect(repo.load().language, AppLanguage.de);
    });

    test('a chosen language is never overwritten', () async {
      final repo = SettingsRepository(prefs);
      await repo.save(repo.load().copyWith(language: AppLanguage.es));
      await repo.keepGermanForEarlierInstalls(existingInstall: true);
      expect(repo.load().language, AppLanguage.es);
    });
  });

  group('Android per-app language', () {
    late FakeNativeLanguage native;
    late AppLanguage setting;
    late SystemLanguageSync sync;

    SystemLanguageSync create() => SystemLanguageSync(
      native: native,
      prefs: prefs,
      current: () => setting,
      adopt: (l) async => setting = l,
    );

    setUp(() {
      native = FakeNativeLanguage('');
      setting = AppLanguage.system;
      sync = create();
    });

    test('the app’s choice is handed to Android', () async {
      setting = AppLanguage.fr;
      await sync.reconcile();
      expect(native.writes, ['fr']);
      setting = AppLanguage.system;
      await sync.push(setting);
      expect(native.writes, ['fr', '']);
    });

    test('nothing is written when Android already agrees', () async {
      native.tag = 'de';
      setting = AppLanguage.de;
      await sync.reconcile();
      expect(native.writes, isEmpty);
    });

    test('a language picked in Android’s settings is taken over', () async {
      setting = AppLanguage.de;
      await sync.reconcile(); // Android now "de", remembered.
      native.tag = 'es-ES'; // changed in Android's settings
      await create().reconcile();
      expect(setting, AppLanguage.es);
      expect(native.writes, ['de'], reason: 'not written back');

      native.tag = ''; // reset to the system language
      await create().reconcile();
      expect(setting, AppLanguage.system);
    });

    test('the change the app made itself is not mistaken for one in '
        'Android’s settings', () async {
      setting = AppLanguage.en;
      await sync.push(setting);
      await sync.reconcile(); // Android reports the new locales
      expect(setting, AppLanguage.en);
      expect(native.writes, ['en']);
    });

    test('before Android 13 nothing happens', () async {
      native.tag = null;
      setting = AppLanguage.fr;
      await sync.reconcile();
      await sync.push(setting);
      expect(native.writes, isEmpty);
      expect(prefs.getString(SystemLanguageSync.preferenceKey), isNull);
    });
  });
}
