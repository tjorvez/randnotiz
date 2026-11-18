import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/l10n/app_language.dart';
import '../domain/app_settings.dart';

/// Persists [AppSettings] in SharedPreferences (app-private storage).
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferencesWithCache _prefs;

  static const keys = {
    'themeMode',
    'lockEnabled',
    'lockTimeoutSeconds',
    'widgetShowsText',
    languageKey,
    birthdayKey,
  };

  static const languageKey = 'appLanguage';
  static const birthdayKey = 'birthday';

  AppSettings load({AppSettings defaults = const AppSettings()}) {
    final theme = _prefs.getString('themeMode');
    return AppSettings(
      themeMode: ThemeMode.values.firstWhere(
        (m) => m.name == theme,
        orElse: () => defaults.themeMode,
      ),
      lockEnabled: _prefs.getBool('lockEnabled') ?? defaults.lockEnabled,
      lockTimeout: _prefs.getInt('lockTimeoutSeconds') != null
          ? Duration(seconds: _prefs.getInt('lockTimeoutSeconds')!)
          : defaults.lockTimeout,
      widgetShowsText:
          _prefs.getBool('widgetShowsText') ?? defaults.widgetShowsText,
      language:
          AppLanguage.fromName(_prefs.getString(languageKey)) ??
          defaults.language,
      birthday: _parseDay(_prefs.getString(birthdayKey)) ?? defaults.birthday,
    );
  }

  Future<void> save(AppSettings s) async {
    await _prefs.setString('themeMode', s.themeMode.name);
    await _prefs.setBool('lockEnabled', s.lockEnabled);
    await _prefs.setInt('lockTimeoutSeconds', s.lockTimeout.inSeconds);
    await _prefs.setBool('widgetShowsText', s.widgetShowsText);
    await _prefs.setString(languageKey, s.language.name);
    final birthday = s.birthday;
    if (birthday == null) {
      await _prefs.remove(birthdayKey);
    } else {
      await _prefs.setString(birthdayKey, _formatDay(birthday));
    }
  }

  /// "1990-05-17" – a calendar day, no time or time zone.
  static String _formatDay(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static DateTime? _parseDay(String? value) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value ?? '');
    if (match == null) return null;
    return DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }

  /// Randnotiz used to speak only German. Installations from that time
  /// ([existingInstall]: the introduction was seen or settings were saved)
  /// keep German instead of switching to the device language; new ones
  /// start with [AppLanguage.system]. Runs once, before the first [load].
  Future<void> keepGermanForEarlierInstalls({
    required bool existingInstall,
  }) async {
    if (_prefs.containsKey(languageKey)) return;
    final settingsSaved = keys.any(
      (k) => k != languageKey && _prefs.containsKey(k),
    );
    if (!existingInstall && !settingsSaved) return;
    await _prefs.setString(languageKey, AppLanguage.de.name);
  }
}
