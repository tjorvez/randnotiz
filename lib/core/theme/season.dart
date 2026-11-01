import 'package:flutter/material.dart';

/// Meteorological seasons (northern hemisphere).
enum Season {
  spring,
  summer,
  autumn,
  winter;

  static Season of(DateTime date) => switch (date.month) {
    3 || 4 || 5 => Season.spring,
    6 || 7 || 8 => Season.summer,
    9 || 10 || 11 => Season.autumn,
    _ => Season.winter,
  };

  /// Small motif shown next to the app bar title.
  IconData get motif => switch (this) {
    Season.spring => Icons.local_florist_outlined,
    Season.summer => Icons.wb_sunny_outlined,
    Season.autumn => Icons.eco_outlined,
    Season.winter => Icons.ac_unit,
  };

  /// Very small hue shift (degrees) applied to the accent colours.
  double get hueShift => switch (this) {
    Season.spring => 6,
    Season.summer => 3,
    Season.autumn => -4,
    Season.winter => -2,
  };

  /// Saturation factor applied to the accent colours.
  double get saturationFactor => switch (this) {
    Season.spring => 1.0,
    Season.summer => 1.06,
    Season.autumn => 1.04,
    Season.winter => 0.85,
  };

  Color motifColor(Brightness brightness) {
    final light = brightness == Brightness.light;
    return switch (this) {
      Season.spring =>
        light ? const Color(0xFFB4687F) : const Color(0xFFE3A9BB),
      Season.summer =>
        light ? const Color(0xFFB07A12) : const Color(0xFFE8C36A),
      Season.autumn =>
        light ? const Color(0xFFA24A26) : const Color(0xFFE39470),
      Season.winter =>
        light ? const Color(0xFF557590) : const Color(0xFFA9C2D6),
    };
  }
}

/// Shifts hue and saturation of [color] slightly, keeping its lightness so
/// contrast stays (almost) unchanged.
Color seasonalShift(Color color, Season season) {
  final hsl = HSLColor.fromColor(color);
  return hsl
      .withHue((hsl.hue + season.hueShift) % 360)
      .withSaturation(
        (hsl.saturation * season.saturationFactor).clamp(0.0, 1.0),
      )
      .toColor();
}
