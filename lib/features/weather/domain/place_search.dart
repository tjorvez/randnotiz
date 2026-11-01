import 'weather.dart';

/// A place found by name. Its name and (town-level) coordinates are stored
/// with a note: for the weather of that day and for the world map.
class Place {
  const Place({
    required this.name,
    required this.location,
    this.region,
    this.country,
  });

  final String name;
  final String? region;
  final String? country;
  final GeoPoint location;

  /// "Name, Region, Land" without empty or duplicate parts.
  String get label {
    final parts = <String>[name];
    for (final p in [region, country]) {
      if (p != null && p.isNotEmpty && !parts.contains(p)) parts.add(p);
    }
    return parts.join(', ');
  }
}

/// Forward geocoding (name → coordinates). Behind an interface for the same
/// licensing reason as [WeatherProvider].
abstract interface class PlaceSearch {
  /// Returns matching places, best match first. Empty on error/offline.
  Future<List<Place>> search(String query, {String language = 'de'});
}
