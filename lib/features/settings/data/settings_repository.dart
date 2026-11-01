import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  };

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
    );
  }

  Future<void> save(AppSettings s) async {
    await _prefs.setString('themeMode', s.themeMode.name);
    await _prefs.setBool('lockEnabled', s.lockEnabled);
    await _prefs.setInt('lockTimeoutSeconds', s.lockTimeout.inSeconds);
    await _prefs.setBool('widgetShowsText', s.widgetShowsText);
  }
}
