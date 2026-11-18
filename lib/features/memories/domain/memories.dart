import 'dart:math';

import '../../notes/domain/note.dart';

/// Memories of one "years ago" distance, e.g. all notes from 3 years ago.
class MemoryGroup {
  const MemoryGroup({required this.yearsAgo, required this.notes});

  final int yearsAgo;
  final List<NoteSummary> notes;
}

sealed class MemoriesResult {
  const MemoriesResult();
}

/// No notes at all yet.
class NoMemories extends MemoriesResult {
  const NoMemories();
}

/// Notes from around today's date in earlier years.
class OnThisDay extends MemoriesResult {
  const OnThisDay(this.groups);
  final List<MemoryGroup> groups;
}

/// Nothing from this day: a random older note instead.
class RandomMemory extends MemoriesResult {
  const RandomMemory(this.note);
  final NoteSummary note;
}

/// Notes exist, but all of them are from the last few days.
class OnlyRecentNotes extends MemoriesResult {
  const OnlyRecentNotes();
}

/// Days of tolerance around the anniversary.
const memoryToleranceDays = 3;

/// Notes younger than this are not offered as "random older note".
const _minAgeForRandom = Duration(days: 14);

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

/// The anniversary of [date] in [year]; 29 February maps to 28 February in
/// non-leap years.
DateTime anniversaryIn(int year, DateTime date) {
  if (date.month == 2 && date.day == 29) {
    final leap = (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
    return DateTime(year, 2, leap ? 29 : 28);
  }
  return DateTime(year, date.month, date.day);
}

/// How many years ago [date] was "on this day" (±[memoryToleranceDays]),
/// or null if it is not a memory for [today].
///
/// Works across year boundaries: the anniversary is searched in last, this
/// and next year. On 2 January 2026 a note from 30 December 2023 matches its
/// anniversary 30 December 2025 and therefore counts as "2 years ago".
int? yearsAgoOnThisDay(DateTime date, DateTime today) {
  final t = _day(today);
  for (final year in [t.year - 1, t.year, t.year + 1]) {
    final anniversary = anniversaryIn(year, date);
    final distance = anniversary.difference(t).inHours.abs() / 24;
    if (distance <= memoryToleranceDays + 0.05) {
      // +0.05 tolerates DST shifts of one hour.
      final years = year - date.year;
      if (years >= 1) return years;
    }
  }
  return null;
}

/// Computes what the memories tab shows for [today].
///
/// The random fallback is stable for a given day (seeded with the date), so
/// the tab does not change on every rebuild.
MemoriesResult computeMemories(List<NoteSummary> notes, DateTime today) {
  if (notes.isEmpty) return const NoMemories();

  final byYears = <int, List<NoteSummary>>{};
  for (final note in notes) {
    final years = yearsAgoOnThisDay(note.date, today);
    if (years != null) byYears.putIfAbsent(years, () => []).add(note);
  }
  if (byYears.isNotEmpty) {
    final keys = byYears.keys.toList()..sort();
    return OnThisDay([
      for (final k in keys)
        MemoryGroup(
          yearsAgo: k,
          notes: byYears[k]!..sort((a, b) => a.date.compareTo(b.date)),
        ),
    ]);
  }

  final cutoff = _day(today).subtract(_minAgeForRandom);
  final older = notes.where((n) => n.date.isBefore(cutoff)).toList()
    ..sort((a, b) => a.id.compareTo(b.id));
  if (older.isEmpty) return const OnlyRecentNotes();
  final seed = today.year * 10000 + today.month * 100 + today.day;
  return RandomMemory(older[Random(seed).nextInt(older.length)]);
}
