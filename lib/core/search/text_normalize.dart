/// Text helpers shared by the search query builder and the UI highlighter.
///
/// The SQLite FTS5 index uses the `unicode61 remove_diacritics 2` tokenizer,
/// i.e. it lowercases and strips diacritics ("Mädchen" is indexed as
/// "madchen"). [foldForSearch] mirrors that behaviour in Dart so the UI can
/// decide locally whether e.g. a tag name matches a query.
library;

const Map<String, String> _diacritics = {
  'ä': 'a',
  'à': 'a',
  'á': 'a',
  'â': 'a',
  'ã': 'a',
  'å': 'a',
  'ö': 'o',
  'ò': 'o',
  'ó': 'o',
  'ô': 'o',
  'õ': 'o',
  'ü': 'u',
  'ù': 'u',
  'ú': 'u',
  'û': 'u',
  'é': 'e',
  'è': 'e',
  'ê': 'e',
  'ë': 'e',
  'í': 'i',
  'ì': 'i',
  'î': 'i',
  'ï': 'i',
  'ç': 'c',
  'ñ': 'n',
};

final RegExp _wordPattern = RegExp(r'[\p{L}\p{N}]+', unicode: true);

/// Lowercases, strips diacritics and maps "ß" to "ss".
String foldForSearch(String input) {
  final lower = input.toLowerCase();
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final char = String.fromCharCode(rune);
    if (char == 'ß') {
      buffer.write('ss');
    } else {
      buffer.write(_diacritics[char] ?? char);
    }
  }
  return buffer.toString();
}

/// Splits text into words (letters and digits, any script).
List<String> splitWords(String input) =>
    _wordPattern.allMatches(input).map((m) => m.group(0)!).toList();

/// All spellings a German user might mean with [token] (already lowercase).
///
/// * "muenchen" also searches "munchen" (ue/ae/oe written for ü/ä/ö),
/// * "strasse" also searches "straße" and vice versa, because the FTS
///   tokenizer does not fold "ß".
Set<String> spellingVariants(String token) {
  final variants = <String>{token};
  void addAll(String Function(String) transform) {
    for (final v in variants.toList()) {
      variants.add(transform(v));
    }
  }

  if (RegExp('ae|oe|ue').hasMatch(token)) {
    addAll(
      (v) =>
          v.replaceAll('ae', 'a').replaceAll('oe', 'o').replaceAll('ue', 'u'),
    );
  }
  if (token.contains('ss')) addAll((v) => v.replaceAll('ss', 'ß'));
  if (token.contains('ß')) addAll((v) => v.replaceAll('ß', 'ss'));
  return variants;
}

/// Whether any word of [text] starts with one of the query [tokens]
/// (comparison after [foldForSearch], including [spellingVariants]).
bool matchesAnyPrefix(String text, Iterable<String> tokens) {
  final words = splitWords(foldForSearch(text));
  for (final token in tokens) {
    for (final variant in spellingVariants(token.toLowerCase())) {
      final folded = foldForSearch(variant);
      if (folded.isEmpty) continue;
      if (words.any((w) => w.startsWith(folded))) return true;
    }
  }
  return false;
}
