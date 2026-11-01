import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/features/memories/domain/memories.dart';
import 'package:randnotiz/features/notes/domain/note.dart';

var _id = 0;
NoteSummary note(DateTime date) => NoteSummary(
  id: ++_id,
  assetId: 'a$_id',
  date: date,
  preview: 'Notiz $_id',
  tags: const [],
);

void main() {
  final today = DateTime(2026, 10, 31, 9, 15);

  group('yearsAgoOnThisDay', () {
    test('same day in earlier years', () {
      expect(yearsAgoOnThisDay(DateTime(2025, 10, 31, 22), today), 1);
      expect(yearsAgoOnThisDay(DateTime(2016, 10, 31), today), 10);
    });

    test('±3 days tolerance, not more', () {
      expect(yearsAgoOnThisDay(DateTime(2023, 10, 28), today), 3);
      expect(yearsAgoOnThisDay(DateTime(2023, 11, 3), today), 3);
      expect(yearsAgoOnThisDay(DateTime(2023, 10, 27), today), isNull);
      expect(yearsAgoOnThisDay(DateTime(2023, 11, 4), today), isNull);
    });

    test('this year never counts', () {
      expect(yearsAgoOnThisDay(DateTime(2026, 10, 30), today), isNull);
      expect(yearsAgoOnThisDay(DateTime(2026, 10, 31), today), isNull);
    });

    test('works across the turn of the year', () {
      final jan2 = DateTime(2026, 1, 2);
      expect(yearsAgoOnThisDay(DateTime(2023, 12, 30), jan2), 2);
      expect(
        yearsAgoOnThisDay(DateTime(2025, 12, 31), jan2),
        isNull,
        reason: 'only two days ago',
      );
      final dec30 = DateTime(2025, 12, 30);
      expect(yearsAgoOnThisDay(DateTime(2024, 1, 2), dec30), 2);
    });

    test('29 February is remembered on 28 February', () {
      expect(
        yearsAgoOnThisDay(DateTime(2024, 2, 29), DateTime(2025, 2, 28)),
        1,
      );
      expect(
        yearsAgoOnThisDay(DateTime(2024, 2, 29), DateTime(2028, 2, 29)),
        4,
      );
    });

    test('daylight saving time does not break the tolerance', () {
      // DST ends on 25 October 2026 in Germany.
      expect(yearsAgoOnThisDay(DateTime(2024, 10, 28, 0, 30), today), 2);
    });
  });

  group('computeMemories', () {
    test('no notes → empty state', () {
      expect(computeMemories(const [], today), isA<NoMemories>());
    });

    test('groups by years ago, nearest first', () {
      final result = computeMemories([
        note(DateTime(2023, 11, 1)),
        note(DateTime(2025, 10, 30)),
        note(DateTime(2023, 10, 29)),
        note(DateTime(2020, 5, 1)),
      ], today);
      expect(result, isA<OnThisDay>());
      final groups = (result as OnThisDay).groups;
      expect(groups.map((g) => g.yearsAgo), [1, 3]);
      expect(groups[1].notes.map((n) => n.date.day), [29, 1]);
    });

    test('falls back to a random older note, stable for the day', () {
      final notes = [for (var m = 1; m <= 8; m++) note(DateTime(2024, m, 10))];
      final a = computeMemories(notes, today);
      final b = computeMemories(notes.reversed.toList(), today);
      expect(a, isA<RandomMemory>());
      expect((a as RandomMemory).note.id, (b as RandomMemory).note.id);
    });

    test('only very recent notes → no random fallback', () {
      final result = computeMemories([note(DateTime(2026, 10, 29))], today);
      expect(result, isA<OnlyRecentNotes>());
    });
  });
}
