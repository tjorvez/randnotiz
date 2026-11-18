import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/features/journal/domain/calendar_days.dart';
import 'package:randnotiz/features/notes/domain/note.dart';

NoteSummary _note(int id, DateTime date) => NoteSummary(
  id: id,
  assetId: 'a$id',
  date: date,
  preview: '',
  tags: const [],
);

void main() {
  group('daysFromToday', () {
    final today = DateTime(2026, 11, 2, 9, 30);

    test('counts whole calendar days, whatever the time of day', () {
      expect(daysFromToday(DateTime(2026, 11, 2, 23, 59), today), 0);
      expect(daysFromToday(DateTime(2026, 11, 1, 23, 59), today), 1);
      expect(daysFromToday(DateTime(2026, 10, 28), today), 5);
      expect(daysFromToday(DateTime(2025, 11, 2), today), 365);
    });

    test('is negative for days to come', () {
      expect(daysFromToday(DateTime(2026, 11, 3), today), -1);
      expect(daysFromToday(DateTime(2026, 12, 2), today), -30);
    });

    test('is not thrown off by the change of the clocks', () {
      // 2026-03-29 is the night the clocks go forward in Europe.
      expect(daysFromToday(DateTime(2026, 3, 28), DateTime(2026, 3, 30)), 2);
      expect(daysFromToday(DateTime(2026, 10, 24), DateTime(2026, 10, 26)), 2);
    });
  });

  group('month grid', () {
    test('leading blanks depend on the first day of the week', () {
      // 1 November 2026 is a Sunday.
      final november = DateTime(2026, 11);
      expect(leadingBlanks(november, 0), 0, reason: 'week starts on Sunday');
      expect(leadingBlanks(november, 1), 6, reason: 'week starts on Monday');
      expect(leadingBlanks(november, 6), 1, reason: 'week starts on Saturday');
      // 1 October 2026 is a Thursday.
      expect(leadingBlanks(DateTime(2026, 10), 1), 3);
    });

    test('a month never needs more than six rows', () {
      for (var m = 1; m <= 12; m++) {
        for (var first = 0; first < 7; first++) {
          final month = DateTime(2026, m);
          final cells = leadingBlanks(month, first) + daysInMonth(month);
          expect((cells / 7).ceil(), lessThanOrEqualTo(6));
        }
      }
    });

    test('knows the length of a month', () {
      expect(daysInMonth(DateTime(2026, 2)), 28);
      expect(daysInMonth(DateTime(2028, 2)), 29);
      expect(daysInMonth(DateTime(2026, 12)), 31);
    });
  });

  test('entries are grouped by day, keeping their order', () {
    final byDay = groupByDay([
      _note(1, DateTime(2026, 10, 28, 20)),
      _note(2, DateTime(2026, 10, 28, 8)),
      _note(3, DateTime(2026, 10, 30)),
    ]);
    expect(byDay.keys, [DateTime(2026, 10, 28), DateTime(2026, 10, 30)]);
    expect([for (final n in byDay[DateTime(2026, 10, 28)]!) n.id], [1, 2]);
  });
}
