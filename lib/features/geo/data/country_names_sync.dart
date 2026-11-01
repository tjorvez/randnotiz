import '../../../core/database/app_database.dart';
import '../domain/geo.dart';

/// Keeps the `countries` table (German and English names for the search
/// index) in line with the bundled geodata. Runs at start-up; rebuilds the
/// search index only when a name changed (first start after the update to
/// schema v7, or new geodata).
class CountryNamesSync {
  CountryNamesSync(this._db);

  final AppDatabase _db;

  /// Returns whether the table changed (and the index was rebuilt).
  Future<bool> sync(List<Country> countries) async {
    final existing = {
      for (final r in await _db.select(_db.countries).get())
        r.code: (r.nameDe, r.nameEn),
    };
    final wanted = {for (final c in countries) c.code: (c.nameDe, c.nameEn)};
    final same =
        existing.length == wanted.length &&
        wanted.entries.every((e) => existing[e.key] == e.value);
    if (same) return false;
    await _db.transaction(() async {
      await _db.delete(_db.countries).go();
      await _db.batch(
        (b) => b.insertAll(_db.countries, [
          for (final c in countries)
            CountriesCompanion.insert(
              code: c.code,
              nameDe: c.nameDe,
              nameEn: c.nameEn,
            ),
        ]),
      );
      await _db.searchIndex.rebuildAll();
    });
    return true;
  }
}
