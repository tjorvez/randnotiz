import 'package:intl/intl.dart';

import '../../features/journal/domain/calendar_days.dart' as calendar;
import '../../features/memories/domain/life_share.dart';
import '../../l10n/generated/app_localizations.dart';

/// Date/number formats used across the app, in the app's language.
abstract final class Fmt {
  /// The app's language ("de"); kept in step with the language setting by
  /// `RandnotizApp` (formatting happens in many places without a context).
  static String locale = 'en';

  /// "Oktober 2026"
  static String month(DateTime d) => DateFormat.yMMMM(locale).format(d);

  /// Short month name alone, e.g. "Okt".
  static String monthName(DateTime d) => DateFormat.MMM(locale).format(d);

  /// "31. Oktober 2026"
  static String longDate(DateTime d) => DateFormat.yMMMMd(locale).format(d);

  /// "Samstag, 31. Oktober 2026"
  static String longDateWithWeekday(DateTime d) =>
      DateFormat.yMMMMEEEEd(locale).format(d);

  /// "Sa., 31. Okt. 2026"
  static String mediumDateWithWeekday(DateTime d) =>
      DateFormat.yMMMEd(locale).format(d);

  /// "31.10.2026", "10/31/2026", "31/10/2026"
  static String shortDate(DateTime d) => locale == 'de'
      ? DateFormat('dd.MM.yyyy', locale).format(d)
      : DateFormat.yMd(locale).format(d);

  /// "31. Okt. 2026"
  static String mediumDate(DateTime d) => DateFormat.yMMMd(locale).format(d);

  /// "Samstag, 31. Oktober 2026, 14:05"
  static String fullDateTime(DateTime d) =>
      '${DateFormat.yMMMMEEEEd(locale).format(d)}, ${DateFormat.Hm(locale).format(d)}';

  /// "21,5" / "21.5"
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

  /// "50 % deines Lebens" – see [lifeShare]. Null without a [birthday] or
  /// where the share means nothing.
  static String? lifeShareOf(
    AppLocalizations l10n,
    DateTime? birthday,
    DateTime date,
    DateTime today,
  ) {
    if (birthday == null) return null;
    final percent = lifeShare(birthday: birthday, date: date, today: today);
    if (percent == null) return null;
    return l10n.lifeShare(
      NumberFormat.percentPattern(locale).format(percent / 100),
    );
  }

  /// "Heute", "Gestern", "Vor 12 Tagen", "Morgen", "In 3 Tagen" – the distance
  /// of [date] from [today] in whole days.
  static String daysFromToday(
    AppLocalizations l10n,
    DateTime date,
    DateTime today,
  ) {
    final days = calendar.daysFromToday(date, today);
    return days >= 0 ? l10n.daysAgo(days) : l10n.calendarDaysAhead(-days);
  }
}
