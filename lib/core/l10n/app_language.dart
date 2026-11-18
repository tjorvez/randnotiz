import 'dart:ui' show Locale;

/// The app's language setting. [system] follows the device; every other
/// value pins one of the translated languages.
enum AppLanguage {
  system,
  en,
  de,
  fr,
  es;

  /// The languages Randnotiz is translated into, in the order they are
  /// offered.
  static const translated = [en, de, fr, es];

  /// The language the app falls back to when the device speaks none of
  /// [translated].
  static const fallback = en;

  /// The stored value for [name], or null for an unknown/missing one.
  static AppLanguage? fromName(String? name) {
    for (final l in values) {
      if (l.name == name) return l;
    }
    return null;
  }

  /// The language's own name ("Français"), so everyone finds theirs no
  /// matter which language is showing. Null for [system].
  String? get nativeName => switch (this) {
    system => null,
    en => 'English',
    de => 'Deutsch',
    fr => 'Français',
    es => 'Español',
  };
}

/// The language the app shows for [setting] on a device that prefers
/// [deviceLocales] (most preferred first): a pinned language as is, the
/// first translated device language for [AppLanguage.system], otherwise
/// English.
AppLanguage resolveAppLanguage(
  AppLanguage setting,
  List<Locale> deviceLocales,
) {
  if (setting != AppLanguage.system) return setting;
  return deviceLanguage(deviceLocales) ?? AppLanguage.fallback;
}

/// The first of [deviceLocales] Randnotiz is translated into, if any.
AppLanguage? deviceLanguage(List<Locale> deviceLocales) {
  for (final locale in deviceLocales) {
    final match = AppLanguage.fromName(locale.languageCode);
    if (match != null && match != AppLanguage.system) return match;
  }
  return null;
}

/// The speech recognition locale for [language] ("fr_CA"): the device's own
/// region if it speaks that language (Canadian French stays Canadian),
/// otherwise the language's home region.
String speechLocaleId(AppLanguage language, List<Locale> deviceLocales) {
  final code = language == AppLanguage.system
      ? AppLanguage.fallback.name
      : language.name;
  for (final locale in deviceLocales) {
    final region = locale.countryCode;
    if (locale.languageCode == code && region != null && region.isNotEmpty) {
      return '${code}_$region';
    }
  }
  return switch (code) {
    'de' => 'de_DE',
    'fr' => 'fr_FR',
    'es' => 'es_ES',
    _ => 'en_US',
  };
}
