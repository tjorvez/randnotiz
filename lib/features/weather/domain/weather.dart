/// Coarse weather categories. The value name is persisted in the database,
/// so never rename existing values (add new ones instead).
enum WeatherKind {
  clear,
  partlyCloudy,
  cloudy,
  fog,
  drizzle,
  rain,
  snow,
  thunderstorm;

  static WeatherKind? fromName(String? name) {
    if (name == null) return null;
    for (final kind in values) {
      if (kind.name == name) return kind;
    }
    return null;
  }

  /// Maps a WMO weather interpretation code (as used by Open-Meteo and most
  /// other weather services) to a [WeatherKind].
  static WeatherKind? fromWmoCode(int code) => switch (code) {
    0 || 1 => WeatherKind.clear,
    2 => WeatherKind.partlyCloudy,
    3 => WeatherKind.cloudy,
    45 || 48 => WeatherKind.fog,
    51 || 53 || 55 || 56 || 57 => WeatherKind.drizzle,
    61 || 63 || 65 || 66 || 67 || 80 || 81 || 82 => WeatherKind.rain,
    71 || 73 || 75 || 77 || 85 || 86 => WeatherKind.snow,
    95 || 96 || 99 => WeatherKind.thunderstorm,
    _ => null,
  };
}

/// The only weather information that is stored: a category and optionally a
/// temperature. Coordinates are never persisted.
class WeatherSnapshot {
  const WeatherSnapshot({required this.kind, this.temperatureC});

  final WeatherKind kind;
  final double? temperatureC;

  WeatherSnapshot copyWith({
    WeatherKind? kind,
    double? Function()? temperatureC,
  }) => WeatherSnapshot(
    kind: kind ?? this.kind,
    temperatureC: temperatureC != null ? temperatureC() : this.temperatureC,
  );

  @override
  bool operator ==(Object other) =>
      other is WeatherSnapshot &&
      other.kind == kind &&
      other.temperatureC == temperatureC;

  @override
  int get hashCode => Object.hash(kind, temperatureC);

  @override
  String toString() => 'WeatherSnapshot($kind, $temperatureC)';
}

/// A location given with reduced precision.
class GeoPoint {
  const GeoPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  /// Rounds to two decimals (~1 km). Only this coarse position is ever sent
  /// to a weather service.
  GeoPoint coarse() => GeoPoint(
    (latitude * 100).roundToDouble() / 100,
    (longitude * 100).roundToDouble() / 100,
  );

  bool get isValid =>
      latitude.abs() <= 90 &&
      longitude.abs() <= 180 &&
      !(latitude == 0 && longitude == 0);

  @override
  bool operator ==(Object other) =>
      other is GeoPoint &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => 'GeoPoint($latitude, $longitude)';
}

/// Source of historical/current weather. Kept behind an interface because the
/// free Open-Meteo tier is for non-commercial use only and may have to be
/// replaced before a store release.
abstract interface class WeatherProvider {
  /// Weather at [location] around [time] (local time of the photo).
  /// Returns null if unknown, offline or the service failed.
  Future<WeatherSnapshot?> weatherAt(GeoPoint location, DateTime time);
}
