import 'package:intl/intl.dart';

import '../../l10n/generated/app_localizations.dart';

/// German date/number formats used across the app.
abstract final class Fmt {
  static const locale = 'de';

  /// "Oktober 2026"
  static String month(DateTime d) => DateFormat.yMMMM(locale).format(d);

  /// "31. Oktober 2026"
  static String longDate(DateTime d) => DateFormat.yMMMMd(locale).format(d);

  /// "Samstag, 31. Oktober 2026"
  static String longDateWithWeekday(DateTime d) =>
      DateFormat.yMMMMEEEEd(locale).format(d);

  /// "Sa., 31. Okt. 2026"
  static String mediumDateWithWeekday(DateTime d) =>
      DateFormat.yMMMEd(locale).format(d);

  /// "31.10.2026"
  static String shortDate(DateTime d) =>
      DateFormat('dd.MM.yyyy', locale).format(d);

  /// "31. Okt. 2026"
  static String mediumDate(DateTime d) => DateFormat.yMMMd(locale).format(d);

  /// "Samstag, 31. Oktober 2026, 14:05"
  static String fullDateTime(DateTime d) =>
      '${DateFormat.yMMMMEEEEd(locale).format(d)}, ${DateFormat.Hm(locale).format(d)}';

  /// "21,5"
  static String temperature(double value) =>
      NumberFormat('#0.#', locale).format(value);

  /// "Vor 3 Jahren", "Vor 2 Monaten", … relative to [today].
  static String ago(AppLocalizations l10n, DateTime date, DateTime today) {
    final d = DateTime(date.year, date.month, date.day);
    final t = DateTime(today.year, today.month, today.day);
    var months = (t.year - d.year) * 12 + t.month - d.month;
    if (t.day < d.day) months--;
    if (months >= 12) return l10n.yearsAgo(months ~/ 12);
    if (months >= 1) return l10n.monthsAgo(months);
    final days = t.difference(d).inHours ~/ 24;
    if (days >= 7) return l10n.weeksAgo(days ~/ 7);
    return l10n.daysAgo(days < 0 ? 0 : days);
  }
}
