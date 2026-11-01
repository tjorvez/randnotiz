import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import '../../../core/search/text_normalize.dart';
import '../../weather/domain/weather.dart';
import '../domain/geo.dart';

/// Offline country outlines and towns, bundled as assets (built by
/// `tools/build_geodata.py` from Natural Earth and GeoNames). Answers
/// "which country / which town is this position in" without any network,
/// and holds the names in German and English.
class GeoDatabase {
  GeoDatabase._({
    required this.countries,
    required this._rings,
    required this._boxes,
    required this._countryGrid,
    required this._placeLat,
    required this._placeLon,
    required this._placeCountry,
    required this._placePopulation,
    required this._placeNameDe,
    required this._placeNameEn,
    required this._placeGrid,
    required this._placesByName,
  }) : _byCode = {for (final (i, c) in countries.indexed) c.code: i};

  static const countriesAsset = 'assets/geo/countries.bin';
  static const placesAsset = 'assets/geo/places.bin';

  /// Towns farther away than this are not "nearby".
  static const maxPlaceDistanceKm = 40.0;

  /// A position outside every outline (coast, simplified border) still gets
  /// the country of a town at most this far away.
  static const coastFallbackKm = 25.0;

  final List<Country> countries;
  final List<List<Float32List>> _rings;
  final Float32List _boxes;
  final Map<int, List<int>> _countryGrid;
  final Map<String, int> _byCode;

  final Int32List _placeLat;
  final Int32List _placeLon;
  final List<String> _placeCountry;
  final Uint32List _placePopulation;
  final List<String> _placeNameDe;
  final List<String?> _placeNameEn;
  final Map<int, List<int>> _placeGrid;
  final Map<String, List<int>> _placesByName;

  int get placeCount => _placeLat.length;

  /// Loads and indexes both assets on a background isolate.
  static Future<GeoDatabase> load([AssetBundle? bundle]) async {
    final b = bundle ?? rootBundle;
    final countries = await b.load(countriesAsset);
    final places = await b.load(placesAsset);
    return Isolate.run(() => parse(countries, places));
  }

  static GeoDatabase parse(ByteData countryData, ByteData placeData) {
    final c = _Reader(countryData)..expectMagic('RNC1');
    final countryCount = c.uint16();
    final countries = <Country>[];
    final rings = <List<Float32List>>[];
    final boxes = Float32List(countryCount * 4);
    final grid = <int, List<int>>{};
    for (var i = 0; i < countryCount; i++) {
      final code = c.ascii(2);
      final flags = c.uint8();
      final markerLon = c.int16() / 100;
      final markerLat = c.int16() / 100;
      final nameDe = c.string();
      final nameEn = c.string();
      final ringCount = c.uint16();
      var minLon = 999.0, minLat = 999.0, maxLon = -999.0, maxLat = -999.0;
      final own = <Float32List>[];
      for (var r = 0; r < ringCount; r++) {
        final n = c.uint32();
        final ring = Float32List(n * 2);
        for (var p = 0; p < n; p++) {
          final lon = c.int16() / 100;
          final lat = c.int16() / 100;
          ring[p * 2] = lon;
          ring[p * 2 + 1] = lat;
          minLon = min(minLon, lon);
          maxLon = max(maxLon, lon);
          minLat = min(minLat, lat);
          maxLat = max(maxLat, lat);
        }
        own.add(ring);
      }
      countries.add(
        Country(
          code: code,
          nameDe: nameDe,
          nameEn: nameEn,
          isSmall: flags & 1 == 1,
          marker: GeoPoint(markerLat, markerLon),
        ),
      );
      rings.add(own);
      boxes
        ..[i * 4] = minLon
        ..[i * 4 + 1] = minLat
        ..[i * 4 + 2] = maxLon
        ..[i * 4 + 3] = maxLat;
      if (own.isEmpty) continue;
      for (var y = _cell(minLat, 10); y <= _cell(maxLat, 10); y++) {
        for (var x = _cell(minLon, 10); x <= _cell(maxLon, 10); x++) {
          grid.putIfAbsent(_key(y, x), () => []).add(i);
        }
      }
    }

    final p = _Reader(placeData)..expectMagic('RNP1');
    final placeCount = p.uint32();
    final lat = Int32List(placeCount);
    final lon = Int32List(placeCount);
    final cc = List<String>.filled(placeCount, '');
    final pop = Uint32List(placeCount);
    final nameDe = List<String>.filled(placeCount, '');
    final nameEn = List<String?>.filled(placeCount, null);
    final placeGrid = <int, List<int>>{};
    final byName = <String, List<int>>{};
    for (var i = 0; i < placeCount; i++) {
      lat[i] = p.int32();
      lon[i] = p.int32();
      cc[i] = p.ascii(2);
      pop[i] = p.uint32();
      nameDe[i] = p.string();
      final en = p.string();
      nameEn[i] = en.isEmpty ? null : en;
      placeGrid
          .putIfAbsent(
            _key(_cell(lat[i] / 1e5, 1), _cell(lon[i] / 1e5, 1)),
            () => [],
          )
          .add(i);
      for (final name in [nameDe[i], ?nameEn[i]]) {
        byName.putIfAbsent(foldForSearch(name), () => []).add(i);
      }
    }
    return GeoDatabase._(
      countries: countries,
      rings: rings,
      boxes: boxes,
      countryGrid: grid,
      placeLat: lat,
      placeLon: lon,
      placeCountry: cc,
      placePopulation: pop,
      placeNameDe: nameDe,
      placeNameEn: nameEn,
      placeGrid: placeGrid,
      placesByName: byName,
    );
  }

  static int _cell(double degrees, int size) => (degrees / size).floor();
  static int _key(int y, int x) => y * 1000 + x;

  Country? country(String? code) {
    final i = code == null ? null : _byCode[code.toUpperCase()];
    return i == null ? null : countries[i];
  }

  /// Outline rings of [code] (interleaved longitude/latitude in degrees).
  List<Float32List> ringsOf(String code) {
    final i = _byCode[code];
    return i == null ? const [] : _rings[i];
  }

  /// The country whose outline contains the position (even-odd rule over
  /// all of its rings, so enclaves like Lesotho work), or null at sea.
  String? countryAt(GeoPoint point) {
    final lat = point.latitude, lon = point.longitude;
    final candidates = _countryGrid[_key(_cell(lat, 10), _cell(lon, 10))];
    if (candidates == null) return null;
    for (final i in candidates) {
      if (lon < _boxes[i * 4] ||
          lat < _boxes[i * 4 + 1] ||
          lon > _boxes[i * 4 + 2] ||
          lat > _boxes[i * 4 + 3]) {
        continue;
      }
      var inside = false;
      for (final ring in _rings[i]) {
        if (_contains(ring, lon, lat)) inside = !inside;
      }
      if (inside) return countries[i].code;
    }
    return null;
  }

  static bool _contains(Float32List ring, double x, double y) {
    var inside = false;
    final n = ring.length ~/ 2;
    for (var i = 0, j = n - 1; i < n; j = i++) {
      final xi = ring[i * 2], yi = ring[i * 2 + 1];
      final xj = ring[j * 2], yj = ring[j * 2 + 1];
      if ((yi > y) != (yj > y) && x < (xj - xi) * (y - yi) / (yj - yi) + xi) {
        inside = !inside;
      }
    }
    return inside;
  }

  /// The town closest to [point] within [maxKm], optionally only in
  /// [countryCode]. Returns its index, or null.
  int? nearestPlaceIndex(
    GeoPoint point, {
    double maxKm = maxPlaceDistanceKm,
    String? countryCode,
  }) {
    final lat = point.latitude, lon = point.longitude;
    final dLat = (maxKm / 111).ceil();
    final cosLat = max(cos(lat * pi / 180), 0.05);
    final dLon = min((maxKm / (111 * cosLat)).ceil(), 180);
    final cy = _cell(lat, 1), cx = _cell(lon, 1);
    int? best;
    var bestKm = maxKm;
    for (var y = cy - dLat; y <= cy + dLat; y++) {
      for (var x = cx - dLon; x <= cx + dLon; x++) {
        // Wrap around the antimeridian.
        final wx = ((x + 180) % 360 + 360) % 360 - 180;
        final cell = _placeGrid[_key(y, wx)];
        if (cell == null) continue;
        for (final i in cell) {
          if (countryCode != null && _placeCountry[i] != countryCode) continue;
          final km = distanceKm(
            point,
            GeoPoint(_placeLat[i] / 1e5, _placeLon[i] / 1e5),
          );
          if (km < bestKm ||
              (km == bestKm &&
                  best != null &&
                  _placePopulation[i] > _placePopulation[best])) {
            best = i;
            bestKm = km;
          }
        }
      }
    }
    return best;
  }

  /// Offline reverse geocoding: country and nearest town of [point].
  GeoMatch resolve(GeoPoint point) {
    var code = countryAt(point);
    var place = nearestPlaceIndex(point, countryCode: code);
    if (code == null) {
      // Just off a (simplified) coast or on a border line: the country of a
      // town close by.
      place = nearestPlaceIndex(point, maxKm: coastFallbackKm);
      code = place == null ? null : _placeCountry[place];
    }
    return _match(code, place);
  }

  /// The best-known town called [name] (German or English, any spelling of
  /// umlauts), e.g. for notes whose place was typed in: "Wien" → AT.
  GeoMatch? lookupPlace(String name) {
    final ids = _placesByName[foldForSearch(name.trim())];
    if (ids == null || ids.isEmpty) return null;
    final best = ids.reduce(
      (a, b) => _placePopulation[a] >= _placePopulation[b] ? a : b,
    );
    return _match(_placeCountry[best], best);
  }

  GeoMatch _match(String? code, int? place) {
    if (place == null) return GeoMatch(countryCode: code);
    final de = _placeNameDe[place];
    final en = _placeNameEn[place];
    return GeoMatch(
      countryCode: code,
      placeName: de,
      placeNameAlt: en == null || en == de ? null : en,
    );
  }

  /// Great-circle distance in kilometres.
  static double distanceKm(GeoPoint a, GeoPoint b) {
    const r = 6371.0;
    final dLat = (b.latitude - a.latitude) * pi / 180;
    final dLon = (b.longitude - a.longitude) * pi / 180;
    final h =
        pow(sin(dLat / 2), 2) +
        cos(a.latitude * pi / 180) *
            cos(b.latitude * pi / 180) *
            pow(sin(dLon / 2), 2);
    return 2 * r * asin(min(1, sqrt(h)));
  }
}

class _Reader {
  _Reader(this._data);

  final ByteData _data;
  int _offset = 0;

  void expectMagic(String magic) {
    if (ascii(4) != magic) {
      throw FormatException('Not a Randnotiz geodata file ($magic)');
    }
  }

  int uint8() => _data.getUint8(_offset++);

  int uint16() {
    final v = _data.getUint16(_offset, Endian.little);
    _offset += 2;
    return v;
  }

  int int16() {
    final v = _data.getInt16(_offset, Endian.little);
    _offset += 2;
    return v;
  }

  int uint32() {
    final v = _data.getUint32(_offset, Endian.little);
    _offset += 4;
    return v;
  }

  int int32() {
    final v = _data.getInt32(_offset, Endian.little);
    _offset += 4;
    return v;
  }

  String ascii(int length) {
    final s = String.fromCharCodes(
      _data.buffer.asUint8List(_data.offsetInBytes + _offset, length),
    );
    _offset += length;
    return s;
  }

  String string() {
    final length = uint8();
    final s = utf8.decode(
      _data.buffer.asUint8List(_data.offsetInBytes + _offset, length),
    );
    _offset += length;
    return s;
  }
}
