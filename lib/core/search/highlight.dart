/// Markers used in SQL `snippet()`/`highlight()` calls. Control characters
/// cannot be typed by the user, so they never collide with note text.
const String highlightStart = '\u0002';
const String highlightEnd = '\u0003';

/// A piece of text that is either a search hit or plain text.
class HighlightPart {
  const HighlightPart(this.text, {required this.isMatch});

  final String text;
  final bool isMatch;

  @override
  bool operator ==(Object other) =>
      other is HighlightPart && other.text == text && other.isMatch == isMatch;

  @override
  int get hashCode => Object.hash(text, isMatch);

  @override
  String toString() => isMatch ? '[$text]' : text;
}

/// Splits text marked with [highlightStart]/[highlightEnd] into parts.
/// Unbalanced markers are tolerated.
List<HighlightPart> parseHighlights(String marked) {
  final parts = <HighlightPart>[];
  final buffer = StringBuffer();
  var inMatch = false;

  void flush() {
    if (buffer.isEmpty) return;
    parts.add(HighlightPart(buffer.toString(), isMatch: inMatch));
    buffer.clear();
  }

  for (final rune in marked.runes) {
    final char = String.fromCharCode(rune);
    if (char == highlightStart) {
      flush();
      inMatch = true;
    } else if (char == highlightEnd) {
      flush();
      inMatch = false;
    } else {
      buffer.write(char);
    }
  }
  flush();
  return parts;
}

/// Removes highlight markers.
String stripHighlights(String marked) =>
    marked.replaceAll(highlightStart, '').replaceAll(highlightEnd, '');
