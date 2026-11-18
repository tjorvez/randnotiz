import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/core/platform/app_info.dart';
import 'package:randnotiz/l10n/generated/app_localizations.dart';

void main() {
  test('"About Randnotiz" names the licence, the author and the source code '
      'in every language', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final legalese = lookupAppLocalizations(
        locale,
      ).settingsAboutLegalese('randnotiz.info', appCopyright, sourceCodeLabel);
      expect(
        legalese,
        contains('GNU General Public License'),
        reason: '$locale',
      );
      expect(legalese, contains(appCopyright), reason: '$locale');
      expect(legalese, contains(sourceCodeLabel), reason: '$locale');
      expect(legalese, contains('randnotiz.info'), reason: '$locale');
    }
  });

  test('the source code label is the repository address without scheme', () {
    expect(sourceCodeLabel, 'github.com/tjorvez/randnotiz');
    expect(Uri.parse('https://$sourceCodeLabel').host, 'github.com');
  });
}
