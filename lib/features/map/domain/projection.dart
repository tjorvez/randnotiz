import 'dart:math';
import 'dart:ui';

/// Equal Earth projection (Šavrič, Patterson & Jenny, 2018): a calm,
/// equal-area world map that keeps the continents in familiar shapes.
///
/// [project] maps longitude/latitude (degrees) into a rectangle of
/// [width] × [height] logical pixels that shows the world from
/// [southLimit] to [northLimit] (Antarctica is left out).
class EqualEarth {
  const EqualEarth(this.width, this.height);

  /// Frames a map of the given height.
  factory EqualEarth.ofHeight(double height) =>
      EqualEarth(height * aspectRatio, height);

  final double width;
  final double height;

  static const southLimit = -58.0;
  static const northLimit = 84.0;

  static const _a1 = 1.340264;
  static const _a2 = -0.081106;
  static const _a3 = 0.000893;
  static const _a4 = 0.003796;
  static final _m = sqrt(3) / 2;

  static final double _xMax = _raw(180, 0).dx;
  static final double _yTop = _raw(0, northLimit).dy;
  static final double _yBottom = _raw(0, southLimit).dy;

  /// Width / height of the framed map.
  static double get aspectRatio => 2 * _xMax / (_yTop - _yBottom);

  static Offset _raw(double lonDeg, double latDeg) {
    final lambda = lonDeg * pi / 180;
    final phi = latDeg * pi / 180;
    final theta = asin(_m * sin(phi));
    final t2 = theta * theta;
    final t6 = t2 * t2 * t2;
    final t8 = t6 * t2;
    final x =
        2 *
        sqrt(3) *
        lambda *
        cos(theta) /
        (3 * (9 * _a4 * t8 + 7 * _a3 * t6 + 3 * _a2 * t2 + _a1));
    final y = theta * (_a4 * t8 + _a3 * t6 + _a2 * t2 + _a1);
    return Offset(x, y);
  }

  /// Position of [lonDeg]/[latDeg] on the map (origin top left).
  Offset project(double lonDeg, double latDeg) {
    final r = _raw(lonDeg, latDeg.clamp(-89.9, 89.9));
    return Offset(
      (r.dx + _xMax) / (2 * _xMax) * width,
      (_yTop - r.dy) / (_yTop - _yBottom) * height,
    );
  }
}
