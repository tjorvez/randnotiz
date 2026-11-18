import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/l10n/app_language.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/season.dart';
import '../features/backup/presentation/lost_notes_prompt.dart';
import '../features/settings/data/settings_repository.dart';
import '../l10n/generated/app_localizations.dart';

/// Stands in for [RandnotizApp] while the notes cannot be opened right now
/// (DatabaseUnavailable) – in the app's language and theme, without anything
/// that needs the database.
class DatabaseUnavailableApp extends StatelessWidget {
  const DatabaseUnavailableApp({
    super.key,
    required this.prefs,
    required this.onRetry,
  });

  final SharedPreferencesWithCache prefs;

  /// Tries to open the notes again (and starts the app if that works).
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final settings = SettingsRepository(prefs).load();
    final language = resolveAppLanguage(
      settings.language,
      PlatformDispatcher.instance.locales,
    );
    final season = Season.of(DateTime.now());
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(Brightness.light, season),
      darkTheme: AppTheme.build(Brightness.dark, season),
      themeMode: settings.themeMode,
      locale: Locale(language.name),
      supportedLocales: [
        for (final l in AppLanguage.translated) Locale(l.name),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: DatabaseUnavailableScreen(onRetry: onRetry),
    );
  }
}
