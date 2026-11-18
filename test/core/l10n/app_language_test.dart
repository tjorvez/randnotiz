import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/core/l10n/app_language.dart';

void main() {
  group('resolveAppLanguage', () {
    test('a pinned language wins over the device', () {
      expect(
        resolveAppLanguage(AppLanguage.fr, const [Locale('de', 'DE')]),
        AppLanguage.fr,
      );
    });

    test('"System": the first translated device language', () {
      for (final (locales, expected) in [
        (const [Locale('de', 'AT')], AppLanguage.de),
        (const [Locale('fr', 'CA')], AppLanguage.fr),
        (const [Locale('es', 'MX')], AppLanguage.es),
        (const [Locale('en', 'GB')], AppLanguage.en),
        // Italian first, Spanish second: Spanish.
        (const [Locale('it', 'IT'), Locale('es', 'ES')], AppLanguage.es),
      ]) {
        expect(
          resolveAppLanguage(AppLanguage.system, locales),
          expected,
          reason: '$locales',
        );
      }
    });

    test('"System" on a device without any of them: English', () {
      expect(
        resolveAppLanguage(AppLanguage.system, const [Locale('it', 'IT')]),
        AppLanguage.en,
      );
      expect(resolveAppLanguage(AppLanguage.system, const []), AppLanguage.en);
    });
  });

  test('stored names round-trip, unknown ones are null', () {
    for (final l in AppLanguage.values) {
      expect(AppLanguage.fromName(l.name), l);
    }
    expect(AppLanguage.fromName('it'), isNull);
    expect(AppLanguage.fromName(null), isNull);
  });

  test('every translation is named in its own language', () {
    expect(AppLanguage.translated.map((l) => l.nativeName), [
      'English',
      'Deutsch',
      'Français',
      'Español',
    ]);
    expect(AppLanguage.system.nativeName, isNull);
  });

  group('speechLocaleId', () {
    test('keeps the device region of the same language', () {
      expect(
        speechLocaleId(AppLanguage.fr, const [Locale('fr', 'CA')]),
        'fr_CA',
      );
      expect(
        speechLocaleId(AppLanguage.es, const [
          Locale('de', 'DE'),
          Locale('es', 'MX'),
        ]),
        'es_MX',
      );
    });

    test('otherwise the language’s home region', () {
      const device = [Locale('de', 'DE')];
      expect(speechLocaleId(AppLanguage.en, device), 'en_US');
      expect(speechLocaleId(AppLanguage.fr, device), 'fr_FR');
      expect(speechLocaleId(AppLanguage.es, device), 'es_ES');
      expect(speechLocaleId(AppLanguage.de, const [Locale('fr')]), 'de_DE');
    });
  });

  test('the ARB files and Android know exactly the translated languages', () {
    final arbs = Directory('lib/l10n')
        .listSync()
        .map((f) => f.uri.pathSegments.last)
        .where((n) => n.endsWith('.arb'))
        .map((n) => n.substring(4, n.length - 4))
        .toSet();
    final codes = AppLanguage.translated.map((l) => l.name).toSet();
    expect(arbs, codes);
    final config = File('android/app/src/main/res/xml/locales_config.xml')
        .readAsStringSync();
    expect(
      RegExp(r'android:name="(\w+)"')
          .allMatches(config)
          .map((m) => m.group(1))
          .toSet(),
      codes,
    );
  });

  test('every translation has every text, with the same placeholders', () {
    Map<String, Object?> read(String code) =>
        jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync())
            as Map<String, Object?>;
    final template = read('en');
    final keys = template.keys.where((k) => !k.startsWith('@')).toSet();
    for (final code in ['de', 'fr', 'es']) {
      final arb = read(code);
      expect(
        arb.keys.where((k) => !k.startsWith('@')).toSet(),
        keys,
        reason: code,
      );
      for (final key in keys) {
        final meta = template['@$key'];
        final placeholders = meta is Map
            ? ((meta['placeholders'] as Map?)?.keys ?? const [])
            : const [];
        for (final p in placeholders) {
          expect(arb[key], contains('{$p'), reason: '$code: $key needs {$p}');
        }
      }
    }
  });
}
