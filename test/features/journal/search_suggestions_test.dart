import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/features/geo/domain/geo.dart';
import 'package:randnotiz/features/journal/data/recent_searches.dart';
import 'package:randnotiz/features/journal/domain/search_suggestions.dart';
import 'package:randnotiz/features/notes/domain/note.dart';
import 'package:randnotiz/features/tags/domain/tag.dart';
import 'package:randnotiz/features/weather/domain/weather.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

const _norway = Country(
  code: 'NO',
  nameDe: 'Norwegen',
  nameEn: 'Norway',
  isSmall: false,
  marker: GeoPoint(60, 8),
);
const _austria = Country(
  code: 'AT',
  nameDe: 'Österreich',
  nameEn: 'Austria',
  isSmall: false,
  marker: GeoPoint(47, 14),
);

void main() {
  SearchSuggestions suggest(
    String query, {
    JournalQuery active = const JournalQuery(),
  }) => buildSuggestions(
    query: query,
    tags: const [
      Tag(id: 1, name: 'Nostalgie', emoji: '😔'),
      Tag(id: 2, name: 'Abenteuer', emoji: '✨'),
    ],
    places: const [
      PlaceUse(name: 'Oslo', countryCode: 'NO', count: 3),
      PlaceUse(name: 'Nordkap', countryCode: 'NO', count: 1),
      PlaceUse(name: 'Wien', countryCode: 'AT', count: 2),
    ],
    countries: const [_norway, _austria],
    countryCounts: const {'NO': 4, 'AT': 2},
    recent: const ['norwegen sommer', 'wien', 'Kaffee'],
    active: active,
  );

  test('grouped by Stimmungen, places, countries and earlier searches', () {
    final s = suggest('no');
    expect(s.tags.map((t) => t.name), ['Nostalgie']);
    expect(s.places.map((p) => p.name), ['Nordkap']);
    expect(s.countries.single.$1.code, 'NO');
    expect(s.countries.single.$2, 4);
    expect(s.recent, ['norwegen sommer']);
  });

  test('countries match in German and English, umlauts folded', () {
    expect(suggest('norway').countries.single.$1, _norway);
    expect(suggest('osterr').countries.single.$1, _austria);
    expect(suggest('aust').countries.single.$1, _austria);
  });

  test('active filters are not offered again', () {
    final s = suggest(
      'no',
      active: const JournalQuery(tagIds: {1}, countryCode: 'NO'),
    );
    expect(s.tags, isEmpty);
    expect(s.countries, isEmpty);
  });

  test('countries without entries are not offered', () {
    final s = buildSuggestions(
      query: 'aus',
      tags: const [],
      places: const [],
      countries: const [_austria],
      countryCounts: const {},
      recent: const [],
    );
    expect(s.isEmpty, isTrue);
  });

  test('an empty field shows only the earlier searches', () {
    final s = suggest('');
    expect(s.recent, ['norwegen sommer', 'wien', 'Kaffee']);
    expect(s.tags, isEmpty);
    expect(s.places, isEmpty);
  });

  group('earlier searches (stored on the device only)', () {
    late RecentSearches store;

    setUp(() async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      store = RecentSearches(
        await SharedPreferencesWithCache.create(
          cacheOptions: const SharedPreferencesWithCacheOptions(
            allowList: {RecentSearches.preferenceKey},
          ),
        ),
      );
    });

    test('newest first, once, limited, removable', () async {
      await store.add('Wien');
      await store.add('Oslo');
      expect(await store.add('  wien '), ['wien', 'Oslo']);
      await store.add('x'); // too short
      for (var i = 0; i < 20; i++) {
        await store.add('Suche $i');
      }
      expect(store.load(), hasLength(RecentSearches.maxEntries));
      expect(store.load().first, 'Suche 19');
      expect(await store.remove('Suche 19'), isNot(contains('Suche 19')));
      await store.clear();
      expect(store.load(), isEmpty);
    });
  });
}
