import 'dart:math';

import '../../memories/domain/memories.dart';
import '../../notes/domain/note.dart';

/// What the home screen widget shows on one particular day.
class WidgetEntry {
  const WidgetEntry({
    required this.day,
    required this.noteId,
    required this.dateLabel,
    required this.agoLabel,
    this.photoPath,
    this.text,
  });

  /// "yyyy-MM-dd" – the native widget picks the entry for the current day.
  final String day;
  final int noteId;
  final String dateLabel;
  final String agoLabel;
  final String? photoPath;

  /// Only set if the user enabled the text preview.
  final String? text;

  Map<String, Object?> toJson() => {
    'day': day,
    'noteId': noteId,
    'dateLabel': dateLabel,
    'agoLabel': agoLabel,
    if (photoPath != null) 'photo': photoPath,
    if (text != null) 'text': text,
  };
}

String isoDay(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Pre-computes the "memory of the day" for [days] days starting at [today],
/// so the widget stays current at midnight without running Dart code.
///
/// The memory of a day is one of its on-this-day notes (chosen stably by the
/// date) or, if there are none, the random older note of the memories tab.
List<WidgetEntry> buildWidgetEntries({
  required List<NoteSummary> notes,
  required DateTime today,
  required bool includeText,
  required String Function(DateTime date) dateLabel,
  required String Function(NoteSummary note, DateTime day, int? yearsAgo)
  agoLabel,
  required String? Function(NoteSummary note) photoPath,
  int days = 7,
  int maxTextLength = 140,
}) {
  final entries = <WidgetEntry>[];
  for (var i = 0; i < days; i++) {
    final day = DateTime(today.year, today.month, today.day + i);
    final result = computeMemories(notes, day);
    NoteSummary? note;
    int? yearsAgo;
    switch (result) {
      case OnThisDay(:final groups):
        final all = [
          for (final g in groups)
            for (final n in g.notes) (g.yearsAgo, n),
        ];
        final pick =
            all[Random(day.year * 10000 + day.month * 100 + day.day)
                .nextInt(all.length)];
        (yearsAgo, note) = pick;
      case RandomMemory(note: final n):
        note = n;
      case NoMemories() || OnlyRecentNotes():
        note = null;
    }
    if (note == null) continue;
    final text = note.preview.trim().replaceAll(RegExp(r'\s+'), ' ');
    entries.add(
      WidgetEntry(
        day: isoDay(day),
        noteId: note.id,
        dateLabel: dateLabel(note.date),
        agoLabel: agoLabel(note, day, yearsAgo),
        photoPath: photoPath(note),
        text: includeText && text.isNotEmpty
            ? (text.length > maxTextLength
                  ? '${text.substring(0, maxTextLength)}…'
                  : text)
            : null,
      ),
    );
  }
  return entries;
}
