import 'package:flutter/foundation.dart';

import '../../../core/search/fts_query.dart';
import '../../../core/search/text_normalize.dart';
import '../../geo/domain/geo.dart';
import '../../notes/domain/note.dart';
import '../../tags/domain/tag.dart';

/// What the journal offers while typing, grouped.
@immutable
class SearchSuggestions {
  const SearchSuggestions({
    this.tags = const [],
    this.places = const [],
    this.countries = const [],
    this.recent = const [],
  });

  /// Stimmungen.
  final List<Tag> tags;
  final List<PlaceUse> places;

  /// Countries with entries, with the number of entries.
  final List<(Country, int)> countries;

  /// Earlier searches.
  final List<String> recent;

  bool get isEmpty =>
      tags.isEmpty && places.isEmpty && countries.isEmpty && recent.isEmpty;
}

/// Suggestions for [query]: Stimmungen, places and countries (German or
/// English name) with a word starting like the query, and earlier searches
/// containing it. Without a query only the earlier searches are offered.
/// Filters that are already active are left out. Only places and countries
/// that have entries are suggested (a filter would find nothing otherwise).
SearchSuggestions buildSuggestions({
  required String query,
  required List<Tag> tags,
  required List<PlaceUse> places,
  required List<Country> countries,
  required Map<String, int> countryCounts,
  required List<String> recent,
  JournalQuery active = const JournalQuery(),
  int perGroup = 4,
}) {
  final tokens = queryTokens(query);
  if (tokens.isEmpty) {
    return SearchSuggestions(recent: recent.take(8).toList());
  }
  bool matches(String text) => matchesAnyPrefix(text, tokens);
  final folded = foldForSearch(query.trim());

  final countryMatches = [
    for (final c in countries)
      if ((countryCounts[c.code] ?? 0) > 0 &&
          c.code != active.countryCode &&
          (matches(c.nameDe) || matches(c.nameEn)))
        (c, countryCounts[c.code]!),
  ]..sort((a, b) => b.$2.compareTo(a.$2));

  return SearchSuggestions(
    tags: [
      for (final t in tags)
        if (!active.tagIds.contains(t.id) && matches(t.name)) t,
    ].take(perGroup).toList(),
    places: [
      for (final p in places)
        if (p.name.toLowerCase() != active.placeName?.toLowerCase() &&
            matches(p.name))
          p,
    ].take(perGroup).toList(),
    countries: countryMatches.take(perGroup).toList(),
    recent: [
      for (final r in recent)
        if (foldForSearch(r).contains(folded) &&
            r.trim().toLowerCase() != query.trim().toLowerCase())
          r,
    ].take(perGroup).toList(),
  );
}
