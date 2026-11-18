import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/core/l10n/app_language.dart';
import 'package:randnotiz/core/platform/app_info.dart';

void main() {
  test('every language opens its own page on randnotiz.info', () {
    expect(
      privacyPolicyUrl(AppLanguage.de).toString(),
      'https://randnotiz.info/de/datenschutz/',
    );
    expect(
      privacyPolicyUrl(AppLanguage.en).toString(),
      'https://randnotiz.info/en/privacy/',
    );
    expect(
      privacyPolicyUrl(AppLanguage.fr).toString(),
      'https://randnotiz.info/fr/confidentialite/',
    );
    expect(
      privacyPolicyUrl(AppLanguage.es).toString(),
      'https://randnotiz.info/es/privacidad/',
    );
    // Never shown (the app resolves "System"), but not a dead link either.
    expect(
      privacyPolicyUrl(AppLanguage.system),
      privacyPolicyUrl(AppLanguage.fallback),
    );
  });

  test('the label is the address without scheme and trailing slash', () {
    expect(privacyPolicyLabel(AppLanguage.de), 'randnotiz.info/de/datenschutz');
    expect(privacyPolicyLabel(AppLanguage.en), 'randnotiz.info/en/privacy');
    expect(
      privacyPolicyLabel(AppLanguage.fr),
      'randnotiz.info/fr/confidentialite',
    );
    expect(privacyPolicyLabel(AppLanguage.es), 'randnotiz.info/es/privacidad');
  });
}
