import 'package:flutter/foundation.dart';

import '../../weather/domain/weather.dart';

/// A country of the offline world map (Natural Earth, public domain).
@immutable
class Country {
  const Country({
    required this.code,
    required this.nameDe,
    required this.nameEn,
    this.nameFr = '',
    this.nameEs = '',
    required this.isSmall,
    required this.marker,
  });

  /// ISO 3166-1 alpha-2, e.g. "NO".
  final String code;
  final String nameDe;
  final String nameEn;
  final String nameFr;
  final String nameEs;

  /// The name in the app's language ([languageCode], e.g. "fr"), English if
  /// there is none.
  String localName(String languageCode) {
    final name = switch (languageCode) {
      'de' => nameDe,
      'fr' => nameFr,
      'es' => nameEs,
      _ => nameEn,
    };
    return name.isEmpty ? nameEn : name;
  }

  /// Another name worth showing next to [localName] (the English one, if
  /// different), so a country is recognised in either language.
  String? otherName(String languageCode) {
    final local = localName(languageCode);
    return nameEn == local ? null : nameEn;
  }

  /// Every name, for searching ("Norvège" and "Norwegen" both find it).
  List<String> get names => [
    nameDe,
    nameEn,
    if (nameFr.isNotEmpty) nameFr,
    if (nameEs.isNotEmpty) nameEs,
  ];

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

  /// Name of the nearest town in the app's language where known: German
  /// for German, otherwise the English/international name (or its usual
  /// name if there is none).
  final String? placeName;

  /// Its other name if different ("Munich" for München, or the other way
  /// round), so searching either finds the note.
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
