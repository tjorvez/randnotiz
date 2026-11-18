import 'package:flutter/foundation.dart';

import '../../notes/domain/note.dart';
import 'memories.dart';

/// The three parts of the memories slider, in this order.
enum MemorySection {
  /// Exactly today's calendar day in earlier years.
  onThisDay,

  /// Up to [memoryToleranceDays] days around today in earlier years.
  aroundThisDay,

  /// Everything else, shuffled.
  more,
}

/// One page of the memories slider.
@immutable
class MemoryPage {
  const MemoryPage({
    required this.note,
    required this.section,
    required this.startsSection,
    this.yearsAgo,
    this.dayOffset = 0,
  });

  final NoteSummary note;
  final MemorySection section;

  /// First page of its section (a quiet divider marks the change).
  final bool startsSection;

  /// For [MemorySection.onThisDay] and [MemorySection.aroundThisDay].
  final int? yearsAgo;

  /// Days between the note's anniversary and today (negative: the
  /// anniversary was a few days ago).
  final int dayOffset;
}

/// How far the anniversary of [date] is from [today]: the number of years
/// and the day offset (anniversary minus today), if within
/// ±[memoryToleranceDays] days in an earlier year. Works across the turn of
/// the year; 29 February counts as 28 February in other years.
({int years, int days})? anniversaryOf(DateTime date, DateTime today) {
  final t = DateTime(today.year, today.month, today.day);
  ({int years, int days})? best;
  for (final year in [t.year - 1, t.year, t.year + 1]) {
    final years = year - date.year;
    if (years < 1) continue;
    final anniversary = anniversaryIn(year, date);
    // Calendar days, immune to daylight saving time.
    final days = DateTime.utc(
      anniversary.year,
      anniversary.month,
      anniversary.day,
    ).difference(DateTime.utc(t.year, t.month, t.day)).inDays;
    if (days.abs() > memoryToleranceDays) continue;
    if (best == null || days.abs() < best.days.abs()) {
      best = (years: years, days: days);
    }
  }
  return best;
}

/// Builds the memories slider for [today]:
///
/// 1. notes from today's calendar day in earlier years – one year ago first,
///    then two, three, …;
/// 2. notes up to ±3 days around it, again by years, then by distance;
/// 3. all other notes in a random order without repetition.
///
/// The random order is stable for a given [seed] (one per app session) and
/// does not depend on the other notes: a note added meanwhile does not
/// reshuffle the rest.
List<MemoryPage> buildMemoryFeed(
  List<NoteSummary> notes,
  DateTime today, {
  required int seed,
}) {
  final exact = <(NoteSummary, int)>[];
  final around = <(NoteSummary, int, int)>[];
  final rest = <NoteSummary>[];
  for (final note in notes) {
    final a = anniversaryOf(note.date, today);
    if (a == null) {
      rest.add(note);
    } else if (a.days == 0) {
      exact.add((note, a.years));
    } else {
      around.add((note, a.years, a.days));
    }
  }

  int byDate(NoteSummary a, NoteSummary b) {
    final c = a.date.compareTo(b.date);
    return c != 0 ? c : a.id.compareTo(b.id);
  }

  exact.sort((a, b) {
    final c = a.$2.compareTo(b.$2);
    return c != 0 ? c : byDate(a.$1, b.$1);
  });
  around.sort((a, b) {
    var c = a.$2.compareTo(b.$2);
    if (c != 0) return c;
    c = a.$3.abs().compareTo(b.$3.abs());
    if (c != 0) return c;
    c = a.$3.compareTo(b.$3);
    return c != 0 ? c : byDate(a.$1, b.$1);
  });
  rest.sort((a, b) {
    final c = shuffleKey(seed, a.id).compareTo(shuffleKey(seed, b.id));
    return c != 0 ? c : a.id.compareTo(b.id);
  });

  return [
    for (final (i, (note, years)) in exact.indexed)
      MemoryPage(
        note: note,
        section: MemorySection.onThisDay,
        startsSection: i == 0,
        yearsAgo: years,
      ),
    for (final (i, (note, years, days)) in around.indexed)
      MemoryPage(
        note: note,
        section: MemorySection.aroundThisDay,
        startsSection: i == 0,
        yearsAgo: years,
        dayOffset: days,
      ),
    for (final (i, note) in rest.indexed)
      MemoryPage(
        note: note,
        section: MemorySection.more,
        startsSection: i == 0,
      ),
  ];
}

/// A pseudo-random sort key for note [id] under [seed] (SplitMix-style
/// mixing, 32 bit so it behaves the same everywhere).
@visibleForTesting
int shuffleKey(int seed, int id) {
  var x = (seed ^ (id * 0x9E3779B1)) & 0xFFFFFFFF;
  x = ((x ^ (x >> 16)) * 0x85EBCA6B) & 0xFFFFFFFF;
  x = ((x ^ (x >> 13)) * 0xC2B2AE35) & 0xFFFFFFFF;
  return x ^ (x >> 16);
}
