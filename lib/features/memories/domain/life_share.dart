import '../../journal/domain/calendar_days.dart' as calendar;

/// How much of the life so far (from [birthday] to [today]) had been lived
/// on [date], in whole percent: age then ÷ age today. At 25 for someone who
/// is 50 today that is 50.
///
/// Counted in calendar days. Null where it means nothing: [date] before the
/// birth or after [today], or [today] not after the birthday. Only [today]
/// itself is 100 – any earlier day stays at 99 at most, even if it rounds up.
int? lifeShare({
  required DateTime birthday,
  required DateTime date,
  required DateTime today,
}) {
  final lived = calendar.daysFromToday(birthday, today);
  final then = calendar.daysFromToday(birthday, date);
  if (lived <= 0 || then < 0 || then > lived) return null;
  if (then == lived) return 100;
  final percent = (then * 100 / lived).round();
  return percent > 99 ? 99 : percent;
}
