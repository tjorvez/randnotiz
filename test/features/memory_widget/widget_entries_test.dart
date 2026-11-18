import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/features/memory_widget/domain/widget_entries.dart';
import 'package:randnotiz/features/notes/domain/note.dart';

NoteSummary note(int id, DateTime date, {String text = 'Geheimer Text'}) =>
    NoteSummary(
      id: id,
      assetId: 'a$id',
      date: date,
      preview: text,
      tags: const [],
      thumbnailFile: 'note_a$id.jpg',
    );

List<WidgetEntry> build(List<NoteSummary> notes, {bool includeText = false}) =>
    buildWidgetEntries(
      notes: notes,
      today: DateTime(2026, 10, 31, 9),
      includeText: includeText,
      dateLabel: (d) => '${d.day}.${d.month}.${d.year}',
      agoLabel: (n, day, years) =>
          years == null ? 'früher' : 'Vor $years Jahren',
      photoPath: (n) => '/data/thumbs/${n.thumbnailFile}',
    );

void main() {
  test('one entry per day for a week, keyed by ISO date', () {
    final entries = build([
      note(1, DateTime(2023, 11, 2)),
      note(2, DateTime(2020, 3, 1)),
    ]);
    expect(entries.map((e) => e.day).toList(), [
      '2026-10-31',
      '2026-11-01',
      '2026-11-02',
      '2026-11-03',
      '2026-11-04',
      '2026-11-05',
      '2026-11-06',
    ]);
    // 2 Nov 2023 is within ±3 days for 31 Oct … 5 Nov.
    expect(entries.first.noteId, 1);
    expect(entries.first.agoLabel, 'Vor 3 Jahren');
    expect(entries.first.photoPath, '/data/thumbs/note_a1.jpg');
    // Later in the week: random older note as fallback.
    expect(entries.last.agoLabel, 'früher');
  });

  test('note text is not written unless the user enabled it', () {
    final hidden = build([note(1, DateTime(2024, 10, 31))]);
    expect(hidden.first.text, isNull);
    expect(hidden.first.toJson().containsKey('text'), isFalse);

    final shown = build([note(1, DateTime(2024, 10, 31))], includeText: true);
    expect(shown.first.text, 'Geheimer Text');
  });

  test('long text is shortened', () {
    final entries = build([
      note(1, DateTime(2024, 10, 31), text: 'x' * 500),
    ], includeText: true);
    expect(entries.first.text!.length, lessThanOrEqualTo(141));
  });

  test(
    'no notes or only fresh notes → no entries (widget shows empty state)',
    () {
      expect(build(const []), isEmpty);
      expect(build([note(1, DateTime(2026, 10, 30))]), isEmpty);
    },
  );
}
