import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/core/theme/logo_colors.dart';

/// The logo colours in Dart must match the icons the launcher shows.
void main() {
  const variants = {
    'standard': LogoColors.standard,
    'spring': LogoColors.spring,
    'summer': LogoColors.summer,
    'autumn': LogoColors.autumn,
    'winter': LogoColors.winter,
  };

  Color color(String hex, [double opacity = 1]) =>
      Color(int.parse(hex, radix: 16) | ((opacity * 255).round() << 24));

  for (final MapEntry(key: name, value: colors) in variants.entries) {
    test('$name matches assets/branding/icon_$name.svg', () {
      final svg = File('assets/branding/icon_$name.svg').readAsStringSync();
      final stops = RegExp(r'<stop [^>]*stop-color="#([0-9A-Fa-f]{6})"')
          .allMatches(svg)
          .map((m) => color(m[1]!))
          .toList();
      // The crayon strokes: every path with a stroke-width and an opacity.
      final crayons = RegExp(
        r'stroke="#([0-9A-Fa-f]{6})" stroke-width="\d+" opacity="([\d.]+)"',
      ).allMatches(svg).map((m) => color(m[1]!, double.parse(m[2]!))).toList();

      expect(colors.gradient, stops);
      expect(colors.crayons, crayons);
    });
  }
}
