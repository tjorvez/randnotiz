import 'text_normalize.dart';

/// Builds a safe SQLite FTS5 MATCH expression from free user input.
///
/// Every word becomes a quoted prefix query, alternative German spellings are
/// OR-ed, and all words must match (implicit AND). Quoting neutralises FTS5
/// syntax characters such as `"`, `*`, `-`, `:` or `NEAR` in user input.
///
/// Returns null if the input contains no searchable word.
String? buildFtsQuery(String input) {
  final words = splitWords(input.toLowerCase());
  if (words.isEmpty) return null;
  final groups = <String>[];
  for (final word in words) {
    final variants = spellingVariants(word).map((v) => '"$v"*').toList()
      ..sort();
    groups.add(
      variants.length == 1 ? variants.single : '(${variants.join(' OR ')})',
    );
  }
  return groups.join(' AND ');
}

/// The words of a query, used to highlight matching tag names in the UI.
List<String> queryTokens(String input) => splitWords(input.toLowerCase());
