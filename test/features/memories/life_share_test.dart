import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/core/format/formatters.dart';
import 'package:randnotiz/features/memories/domain/life_share.dart';
import 'package:randnotiz/l10n/generated/app_localizations_de.dart';
import 'package:randnotiz/l10n/generated/app_localizations_en.dart';

void main() {
  int? share(DateTime birthday, DateTime date, DateTime today) =>
      lifeShare(birthday: birthday, date: date, today: today);

  test('at 25, for someone who is 50 today, half the life was lived', () {
    expect(
      share(
        DateTime(1976, 3, 14),
        DateTime(2001, 3, 14),
        DateTime(2026, 3, 14),
      ),
      50,
    );
  });

  test('the birthday itself is 0 %, today 100 %', () {
    final birthday = DateTime(1990, 6, 1);
    final today = DateTime(2026, 11, 13);
    expect(share(birthday, birthday, today), 0);
    expect(share(birthday, today, today), 100);
  });

  test('a day just before today stays below 100', () {
    expect(
      share(
        DateTime(1990, 6, 1),
        DateTime(2026, 11, 12),
        DateTime(2026, 11, 13),
      ),
      99,
    );
  });

  test('time of day and leap years do not matter', () {
    // Born on a leap day; 20 of 40 years.
    expect(
      share(
        DateTime(1984, 2, 29, 23, 59),
        DateTime(2004, 2, 29, 0, 1),
        DateTime(2024, 2, 29, 12),
      ),
      50,
    );
  });

  test('no share before the birth, in the future or without a life yet', () {
    final birthday = DateTime(2000, 1, 1);
    final today = DateTime(2026, 1, 1);
    expect(share(birthday, DateTime(1999, 12, 31), today), isNull);
    expect(share(birthday, DateTime(2026, 1, 2), today), isNull);
    expect(share(today, today, today), isNull);
    expect(share(DateTime(2027, 1, 1), today, today), isNull);
  });

  test('formatted in the language of the app', () {
    final birthday = DateTime(1976, 3, 14);
    final date = DateTime(2001, 3, 14);
    final today = DateTime(2026, 3, 14);
    Fmt.locale = 'de';
    expect(
      Fmt.lifeShareOf(AppLocalizationsDe(), birthday, date, today),
      '50 % deines Lebens',
    );
    Fmt.locale = 'en';
    expect(
      Fmt.lifeShareOf(AppLocalizationsEn(), birthday, date, today),
      '50% of your life',
    );
    expect(Fmt.lifeShareOf(AppLocalizationsEn(), null, date, today), isNull);
  });
}
