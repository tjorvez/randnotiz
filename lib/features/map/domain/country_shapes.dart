import 'dart:ui';

import '../../geo/data/geo_database.dart';
import '../../geo/domain/geo.dart';
import 'projection.dart';

/// All country outlines projected once for a map of a given size, so
/// panning and zooming only transform the canvas – nothing is recomputed.
/// Also answers which country (or small-state marker) a tap hit.
class CountryShapes {
  CountryShapes._(this.projection, this._paths, this._markers, this.borders);

  factory CountryShapes.build(GeoDatabase geo, EqualEarth projection) {
    final paths = <String, Path>{};
    final markers = <String, Offset>{};
    final borders = Path();
    for (final c in geo.countries) {
      final rings = geo.ringsOf(c.code);
      if (rings.isNotEmpty) {
        final path = Path()..fillType = PathFillType.evenOdd;
        for (final ring in rings) {
          final first = projection.project(ring[0], ring[1]);
          path.moveTo(first.dx, first.dy);
          for (var i = 2; i < ring.length; i += 2) {
            final p = projection.project(ring[i], ring[i + 1]);
            path.lineTo(p.dx, p.dy);
          }
          path.close();
        }
        paths[c.code] = path;
        borders.addPath(path, Offset.zero);
      }
      if (c.isSmall) {
        markers[c.code] = projection.project(
          c.marker.longitude,
          c.marker.latitude,
        );
      }
    }
    return CountryShapes._(projection, paths, markers, borders);
  }

  final EqualEarth projection;
  final Map<String, Path> _paths;
  final Map<String, Offset> _markers;

  /// Every outline in one path (for drawing the borders).
  final Path borders;

  Path? pathOf(String code) => _paths[code];

  /// Small countries get a marker at this map position.
  Map<String, Offset> get markers => _markers;

  /// All outlines of [codes] in one path (e.g. countries with entries).
  Path combined(Iterable<String> codes) {
    final path = Path()..fillType = PathFillType.evenOdd;
    for (final code in codes) {
      final p = _paths[code];
      if (p != null) path.addPath(p, Offset.zero);
    }
    return path;
  }

  /// Map-space bounds of [codes] (markers included), or null.
  Rect? boundsOf(Iterable<String> codes) {
    Rect? bounds;
    for (final code in codes) {
      final marker = _markers[code];
      final r = marker != null
          ? Rect.fromCenter(center: marker, width: 1, height: 1)
          : _paths[code]?.getBounds();
      if (r == null) continue;
      bounds = bounds == null ? r : bounds.expandToInclude(r);
    }
    return bounds;
  }

  /// The country at [point] (map coordinates). Small-state markers win if
  /// the tap is within [markerRadius] (map units) of one – preferring
  /// [preferred] codes (e.g. those with entries) when several are close.
  String? hit(
    Offset point, {
    required double markerRadius,
    Set<String> preferred = const {},
  }) {
    String? bestMarker;
    var bestDistance = double.infinity;
    for (final MapEntry(key: code, value: pos) in _markers.entries) {
      final d = (pos - point).distance;
      if (d > markerRadius) continue;
      final rank = preferred.contains(code) ? d - markerRadius : d;
      if (rank < bestDistance) {
        bestDistance = rank;
        bestMarker = code;
      }
    }
    if (bestMarker != null) return bestMarker;
    for (final MapEntry(key: code, value: path) in _paths.entries) {
      if (path.getBounds().contains(point) && path.contains(point)) {
        return code;
      }
    }
    return null;
  }
}

/// Codes of [counts] with at least one entry.
Set<String> countriesWithEntries(Map<String, int> counts) => {
  for (final MapEntry(key: code, value: n) in counts.entries)
    if (n > 0) code,
};

/// The country's display name (German) – falls back to the code.
String countryName(GeoDatabase? geo, String code) =>
    geo?.country(code)?.nameDe ?? code;

/// Flag and name, e.g. "🇳🇴 Norwegen".
String countryLabel(Country c) => '${c.flag} ${c.nameDe}';
