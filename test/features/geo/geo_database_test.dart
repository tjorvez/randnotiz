import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/features/geo/data/geo_database.dart';
import 'package:randnotiz/features/geo/domain/geo.dart';
import 'package:randnotiz/features/weather/domain/weather.dart';

void main() {
  late GeoDatabase geo;

  setUpAll(() {
    ByteData read(String path) =>
        ByteData.sublistView(File(path).readAsBytesSync());
    geo = GeoDatabase.parse(
      read(GeoDatabase.countriesAsset),
      read(GeoDatabase.placesAsset),
    );
  });

  GeoMatch at(double lat, double lon) => geo.resolve(GeoPoint(lat, lon));

  test('the bundled data is complete', () {
    expect(geo.countries.length, greaterThan(230));
    expect(geo.placeCount, greaterThan(30000));
    expect(geo.country('NO')!.nameDe, 'Norwegen');
    expect(geo.country('NO')!.nameEn, 'Norway');
    expect(geo.country('FR')!.nameDe, 'Frankreich');
    expect(geo.country('VA')!.isSmall, isTrue);
    expect(geo.country('DE')!.isSmall, isFalse);
    expect(flagEmoji('NO'), '🇳🇴');
  });

  test('country and nearest town, names in German and English', () {
    expect(
      at(48.137, 11.575),
      const GeoMatch(
        countryCode: 'DE',
        placeName: 'München',
        placeNameAlt: 'Munich',
      ),
    );
    expect(at(59.913, 10.752).countryCode, 'NO');
    expect(at(59.913, 10.752).placeName, 'Oslo');
    expect(at(48.208, 16.372).placeName, 'Wien');
    expect(at(-33.92, 18.42).countryCode, 'ZA');
    expect(at(35.68, 139.69).countryCode, 'JP');
    expect(at(40.71, -74.0).countryCode, 'US');
  });

  test('enclaves, borders and coasts', () {
    // Maseru lies in Lesotho, which is a hole in South Africa.
    expect(at(-29.31, 27.48).countryCode, 'LS');
    // Kehl (DE) faces Strasbourg (FR): the town is taken from the country.
    expect(at(48.572, 7.815).countryCode, 'DE');
    expect(at(48.583, 7.745).countryCode, 'FR');
    // On the beach, just outside the simplified outline: the country of
    // the town close by.
    expect(at(-22.9714, -43.1823).countryCode, 'BR'); // Copacabana
    // Too small for a 1:50m outline: found through its town.
    expect(at(43.7384, 7.4246).countryCode, 'MC');
    expect(at(47.14, 9.52).countryCode, 'LI');
  });

  test('the open sea has no country and no town', () {
    final m = at(30.0, -40.0);
    expect(m.countryCode, isNull);
    expect(m.placeName, isNull);
    expect(m.isEmpty, isTrue);
  });

  test('places can be found by name, any umlaut spelling', () {
    expect(geo.lookupPlace('Wien')!.countryCode, 'AT');
    expect(geo.lookupPlace('vienna')!.placeName, 'Wien');
    expect(geo.lookupPlace('München')!.placeNameAlt, 'Munich');
    expect(geo.lookupPlace('Rom')!.countryCode, 'IT', reason: 'largest Rome');
    expect(geo.lookupPlace('Xyzzy'), isNull);
  });

  test('lookups are fast', () {
    final watch = Stopwatch()..start();
    for (var i = 0; i < 2000; i++) {
      geo.resolve(GeoPoint(-60 + (i * 7919 % 13000) / 100, -180 + i * 0.18));
    }
    // ~2000 lookups well under a second even in debug mode.
    expect(watch.elapsedMilliseconds, lessThan(1500));
  });
}
