import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/features/memories/domain/memory_feed.dart';
import 'package:randnotiz/features/notes/domain/note.dart';

NoteSummary _note(int id, DateTime date) => NoteSummary(
  id: id,
  assetId: 'a$id',
  date: date,
  preview: 'Notiz $id',
  tags: const [],
);

void main() {
  final today = DateTime(2026, 10, 31, 9, 30);

  group('anniversaryOf', () {
    test('years and day offset, both directions', () {
      expect(anniversaryOf(DateTime(2025, 10, 31, 23), today), (
        years: 1,
        days: 0,
      ));
      expect(anniversaryOf(DateTime(2023, 11, 2), today), (years: 3, days: 2));
      expect(anniversaryOf(DateTime(2020, 10, 28), today), (
        years: 6,
        days: -3,
      ));
      expect(anniversaryOf(DateTime(2020, 10, 27), today), isNull);
      expect(
        anniversaryOf(DateTime(2026, 10, 31), today),
        isNull,
        reason: 'same year',
      );
    });

    test('across the turn of the year and on leap days', () {
      // 2 January: 30 December two years earlier is "3 days ago, 2 years".
      expect(anniversaryOf(DateTime(2023, 12, 30), DateTime(2026, 1, 2)), (
        years: 2,
        days: -3,
      ));
      expect(anniversaryOf(DateTime(2024, 1, 3), DateTime(2025, 12, 31)), (
        years: 2,
        days: 3,
      ));
      // 29 February counts as 28 February in other years.
      expect(anniversaryOf(DateTime(2024, 2, 29), DateTime(2027, 2, 28)), (
        years: 3,
        days: 0,
      ));
      expect(anniversaryOf(DateTime(2024, 2, 29), DateTime(2028, 2, 29)), (
        years: 4,
        days: 0,
      ));
    });

    test('daylight saving time does not shift the offset', () {
      // 25 October 2026 is the end of summer time in Germany.
      expect(anniversaryOf(DateTime(2022, 10, 28, 0, 30), today), (
        years: 4,
        days: -3,
      ));
    });
  });

  group('buildMemoryFeed', () {
    final notes = [
      _note(1, DateTime(2023, 10, 31, 18)), // exact, 3 years
      _note(2, DateTime(2025, 10, 31, 8)), // exact, 1 year
      _note(3, DateTime(2024, 10, 31, 12)), // exact, 2 years
      _note(4, DateTime(2025, 10, 31, 7)), // exact, 1 year, earlier
      _note(5, DateTime(2025, 11, 2)), // around, 1 year, +2
      _note(6, DateTime(2025, 10, 30)), // around, 1 year, -1
      _note(7, DateTime(2022, 11, 1)), // around, 4 years, +1
      _note(8, DateTime(2025, 10, 29)), // around, 1 year, -2
      for (var i = 9; i < 40; i++) _note(i, DateTime(2026, 3, i % 28 + 1)),
      _note(40, DateTime(2026, 10, 31)), // today: no memory yet
    ];

    test(
      'on this day first (1 year ago first), then around, then the rest',
      () {
        final feed = buildMemoryFeed(notes, today, seed: 7);
        expect(feed.map((p) => p.note.id).take(8), [4, 2, 3, 1, 6, 8, 5, 7]);
        expect(
          feed.take(4).map((p) => p.section),
          everyElement(MemorySection.onThisDay),
        );
        expect(
          feed.skip(4).take(4).map((p) => p.section),
          everyElement(MemorySection.aroundThisDay),
        );
        expect(
          feed.skip(8).map((p) => p.section),
          everyElement(MemorySection.more),
        );
        expect(feed[1].yearsAgo, 1);
        expect(feed[5].dayOffset, -2);
        // Quiet dividers exactly where a section starts.
        expect(
          [
            for (final (i, p) in feed.indexed)
              if (p.startsSection) i,
          ],
          [0, 4, 8],
        );
      },
    );

    test('the rest: every note once, shuffled, stable per session', () {
      final a = buildMemoryFeed(notes, today, seed: 7);
      final b = buildMemoryFeed(notes.reversed.toList(), today, seed: 7);
      final c = buildMemoryFeed(notes, today, seed: 8);
      List<int> rest(List<MemoryPage> f) => [
        for (final p in f)
          if (p.section == MemorySection.more) p.note.id,
      ];
      expect(rest(a), rest(b), reason: 'same seed, same order');
      expect(rest(a).toSet(), hasLength(rest(a).length), reason: 'no repeats');
      expect(rest(a).toSet(), {for (var i = 9; i <= 40; i++) i});
      expect(rest(a), isNot(rest(c)), reason: 'another session, other order');
      expect(
        rest(a),
        isNot([for (var i = 9; i <= 40; i++) i]),
        reason: 'shuffled',
      );

      // A new note does not reshuffle the others.
      final more = buildMemoryFeed(
        [...notes, _note(99, DateTime(2026, 4, 1))],
        today,
        seed: 7,
      );
      expect(rest(more).where((id) => id != 99), rest(a));
    });

    test('without anniversaries everything is in the shuffled part', () {
      final feed = buildMemoryFeed(
        [_note(1, DateTime(2026, 5, 1))],
        today,
        seed: 1,
      );
      expect(feed.single.section, MemorySection.more);
      expect(feed.single.startsSection, isTrue);
      expect(buildMemoryFeed(const [], today, seed: 1), isEmpty);
    });
  });
}
