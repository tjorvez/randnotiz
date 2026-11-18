import 'package:flutter/material.dart';

import '../../../core/l10n/app_language.dart';

/// Lock timeouts offered in the settings.
const List<Duration> lockTimeoutOptions = [
  Duration.zero,
  Duration(minutes: 1),
  Duration(minutes: 5),
  Duration(minutes: 15),
];

@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.lockEnabled = true,
    this.lockTimeout = const Duration(minutes: 1),
    this.widgetShowsText = false,
    this.language = AppLanguage.system,
    this.birthday,
  });

  final ThemeMode themeMode;

  /// Biometric/device-credential lock. On by default; only effective if the
  /// device has a screen lock.
  final bool lockEnabled;

  /// How long the app may stay in the background before it locks again.
  final Duration lockTimeout;

  /// Whether the home screen widget may show note text (off by default).
  final bool widgetShowsText;

  /// The language of the app; [AppLanguage.system] follows the device
  /// (English if the device speaks none of the translated languages).
  final AppLanguage language;

  /// Optional, only for "x % of your life" next to memories (date only).
  final DateTime? birthday;

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? lockEnabled,
    Duration? lockTimeout,
    bool? widgetShowsText,
    AppLanguage? language,
    DateTime? birthday,
    bool clearBirthday = false,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    lockEnabled: lockEnabled ?? this.lockEnabled,
    lockTimeout: lockTimeout ?? this.lockTimeout,
    widgetShowsText: widgetShowsText ?? this.widgetShowsText,
    language: language ?? this.language,
    birthday: clearBirthday ? null : birthday ?? this.birthday,
  );
}
