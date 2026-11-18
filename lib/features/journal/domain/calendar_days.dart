import '../../notes/domain/note.dart';

/// [d] without its time of day.
DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

/// The first day of [d]'s month.
DateTime monthOf(DateTime d) => DateTime(d.year, d.month);

/// [notes] by the calendar day they belong to; the order within a day is the
/// order of [notes].
Map<DateTime, List<NoteSummary>> groupByDay(Iterable<NoteSummary> notes) {
  final byDay = <DateTime, List<NoteSummary>>{};
  for (final n in notes) {
    byDay.putIfAbsent(dayOf(n.date), () => []).add(n);
  }
  return byDay;
}

/// Whole calendar days from [date] to [today]: positive if [date] lies in the
/// past, 0 for today, negative in the future. Counted on dates, so a change
/// of the clocks does not shift it.
int daysFromToday(DateTime date, DateTime today) => DateTime.utc(
  today.year,
  today.month,
  today.day,
).difference(DateTime.utc(date.year, date.month, date.day)).inDays;

/// How many empty cells a month grid needs before the 1st of [month], when
/// weeks start on [firstDayOfWeek] (0 = Sunday … 6 = Saturday, like
/// `MaterialLocalizations.firstDayOfWeekIndex`).
int leadingBlanks(DateTime month, int firstDayOfWeek) =>
    (DateTime(month.year, month.month).weekday % 7 - firstDayOfWeek + 7) % 7;

/// Number of days in [month].
int daysInMonth(DateTime month) => DateTime(month.year, month.month + 1, 0).day;
