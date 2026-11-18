import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/core/platform/secure_window.dart';
import 'package:randnotiz/features/geo/data/geo_database.dart';
import 'package:randnotiz/features/map/data/world_shapes.dart';
import 'package:randnotiz/features/map/domain/country_shapes.dart';
import 'package:randnotiz/features/map/domain/projection.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('projection', () {
    const map = EqualEarth(1000, 480);

    test('north is up, east is right', () {
      final hamburg = map.project(10, 53.5);
      final rome = map.project(12.5, 41.9);
      final tokyo = map.project(139.7, 35.7);
      final newYork = map.project(-74, 40.7);
      expect(hamburg.dy, lessThan(rome.dy));
      expect(tokyo.dx, greaterThan(hamburg.dx));
      expect(newYork.dx, lessThan(hamburg.dx));
    });

    test('the framed world fills the rectangle', () {
      expect(map.project(0, 0).dx, closeTo(500, 0.01));
      expect(map.project(-180, 0).dx, closeTo(0, 0.01));
      expect(map.project(180, 0).dx, closeTo(1000, 0.01));
      expect(map.project(0, EqualEarth.northLimit).dy, closeTo(0, 0.01));
      expect(map.project(0, EqualEarth.southLimit).dy, closeTo(480, 0.01));
      expect(EqualEarth.aspectRatio, inInclusiveRange(1.9, 2.3));
    });
  });

  test('the bundled land outlines load', () async {
    final data = await rootBundle.load(WorldShapes.asset);
    final rings = WorldShapes.parse(data);
    expect(rings.length, greaterThan(100));
    for (final ring in rings) {
      expect(ring.length.isEven, isTrue);
      expect(ring.length, greaterThanOrEqualTo(8));
    }
    expect(
      () => WorldShapes.parse(ByteData(8)),
      throwsA(isA<FormatException>()),
    );
  });

  group('country shapes', () {
    late GeoDatabase geo;
    late CountryShapes shapes;
    const projection = EqualEarth(2000, 960);

    setUpAll(() {
      ByteData read(String path) =>
          ByteData.sublistView(File(path).readAsBytesSync());
      geo = GeoDatabase.parse(
        read(GeoDatabase.countriesAsset),
        read(GeoDatabase.placesAsset),
      );
      shapes = CountryShapes.build(geo, projection);
    });

    Offset at(double lat, double lon) => projection.project(lon, lat);

    test('a tap finds the country under it', () {
      expect(shapes.hit(at(60.4, 8.5), markerRadius: 0), 'NO');
      expect(shapes.hit(at(51, 10), markerRadius: 0), 'DE');
      expect(shapes.hit(at(-25, 134), markerRadius: 0), 'AU');
      expect(shapes.hit(at(30, -40), markerRadius: 0), isNull, reason: 'sea');
      // Lesotho is a hole in South Africa's outline.
      expect(shapes.hit(at(-29.5, 28.2), markerRadius: 0), 'LS');
    });

    test('small countries have markers that win near them', () {
      expect(shapes.markers.keys, containsAll(['VA', 'MC', 'SG', 'LU']));
      expect(shapes.markers.keys, isNot(contains('DE')));
      final monaco = shapes.markers['MC']!;
      expect(shapes.hit(monaco + const Offset(1, 1), markerRadius: 4), 'MC');
      // With entries in Vatican City, the Vatican wins over nearby Rome.
      final vatican = shapes.markers['VA']!;
      expect(shapes.hit(vatican, markerRadius: 6, preferred: {'VA'}), 'VA');
    });

    test('highlighting combines outlines; bounds include markers', () {
      final path = shapes.combined(['NO', 'DE']);
      expect(path.contains(at(60.4, 8.5)), isTrue);
      expect(path.contains(at(51, 10)), isTrue);
      expect(path.contains(at(46.8, 8.2)), isFalse); // Switzerland
      final bounds = shapes.boundsOf(['DE', 'MC'])!;
      expect(bounds.contains(shapes.markers['MC']!), isTrue);
      expect(shapes.boundsOf(const []), isNull);
      expect(countriesWithEntries({'NO': 2, 'DE': 0}), {'NO'});
    });
  });

  group('screenshots', () {
    bool secure({
      bool lockEnabled = true,
      bool lockAvailable = true,
      bool lockBypassed = false,
      bool releaseBuild = true,
    }) => windowShouldBeSecure(
      lockEnabled: lockEnabled,
      lockAvailable: lockAvailable,
      lockBypassed: lockBypassed,
      releaseBuild: releaseBuild,
    );

    test('release: blocked only while the lock is in effect', () {
      expect(secure(), isTrue);
      expect(secure(lockEnabled: false), isFalse);
      // No screen lock on the device → the app cannot lock → allowed.
      expect(secure(lockAvailable: false), isFalse);
      expect(secure(lockBypassed: true), isFalse);
    });

    test('debug and profile builds never block screenshots', () {
      expect(secure(releaseBuild: false), isFalse);
    });
  });
}
