import 'package:flutter/foundation.dart';

import '../../weather/domain/weather.dart';

/// A country of the offline world map (Natural Earth, public domain).
@immutable
class Country {
  const Country({
    required this.code,
    required this.nameDe,
    required this.nameEn,
    required this.isSmall,
    required this.marker,
  });

  /// ISO 3166-1 alpha-2, e.g. "NO".
  final String code;
  final String nameDe;
  final String nameEn;

  /// Too small to tap on a world map: drawn with a marker.
  final bool isSmall;

  /// Where the marker (or a label) goes.
  final GeoPoint marker;

  /// "🇳🇴" – the flag emoji of [code].
  String get flag => flagEmoji(code);
}

/// The flag emoji of an ISO 3166-1 alpha-2 [code] ("NO" → 🇳🇴).
String flagEmoji(String code) {
  if (code.length != 2) return '';
  final upper = code.toUpperCase();
  const base = 0x1F1E6 - 0x41; // regional indicator "A" minus "A"
  return String.fromCharCodes([
    base + upper.codeUnitAt(0),
    base + upper.codeUnitAt(1),
  ]);
}

/// Country and nearest town of a position (offline reverse geocoding). Only
/// these names are ever stored – never the position itself.
@immutable
class GeoMatch {
  const GeoMatch({this.countryCode, this.placeName, this.placeNameAlt});

  final String? countryCode;

  /// German name of the nearest town (or its usual name if there is none).
  final String? placeName;

  /// Its English/international name if different ("Munich" for München),
  /// so searching either finds the note.
  final String? placeNameAlt;

  bool get isEmpty => countryCode == null && placeName == null;

  @override
  bool operator ==(Object other) =>
      other is GeoMatch &&
      other.countryCode == countryCode &&
      other.placeName == placeName &&
      other.placeNameAlt == placeNameAlt;

  @override
  int get hashCode => Object.hash(countryCode, placeName, placeNameAlt);

  @override
  String toString() => 'GeoMatch($countryCode, $placeName, $placeNameAlt)';
}
