import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'season.dart';

/// The colours of the logo's photo: its gradient and the five crayon
/// strokes (with their opacity), as in `assets/branding/icon_<variant>.svg`
/// (`test/core/theme/logo_colors_test.dart` keeps them in step). The line
/// is not part of it; it follows light and dark.
@immutable
class LogoColors {
  const LogoColors({required this.gradient, required this.crayons});

  /// Top left to bottom right.
  final List<Color> gradient;

  /// In drawing order.
  final List<Color> crayons;

  /// The launcher icon right after installing; also the native start screen.
  static const standard = LogoColors(
    gradient: [Color(0xFFFFE3CB), Color(0xFFFBD0D6)],
    crayons: [
      Color(0xE6FFBE94),
      Color(0xD9F7B2A0),
      Color(0xE6F4A1B6),
      Color(0xF2FFD7A8),
      Color(0xE6E68AA3),
    ],
  );

  static const spring = LogoColors(
    gradient: [Color(0xFFEEF4DA), Color(0xFFFBE3EA)],
    crayons: [
      Color(0xE6C9E09E),
      Color(0xD9FBE08F),
      Color(0xE6F6B5C9),
      Color(0xF2F29BB6),
      Color(0xE69CC77E),
    ],
  );

  static const summer = LogoColors(
    gradient: [Color(0xFFFFE6BE), Color(0xFFFFD9C8)],
    crayons: [
      Color(0xE6FFBC6E),
      Color(0xD99FD5CC),
      Color(0xE6F58D7C),
      Color(0xF2FFD45E),
      Color(0xE6F2707A),
    ],
  );

  static const autumn = LogoColors(
    gradient: [Color(0xFFF7DDB0), Color(0xFFF0C9A4)],
    crayons: [
      Color(0xE6E9A04F),
      Color(0xD9C6A15C),
      Color(0xE6C9674A),
      Color(0xF2E7BE6A),
      Color(0xE69E4E3A),
    ],
  );

  static const winter = LogoColors(
    gradient: [Color(0xFFEEF3F7), Color(0xFFEAE2EF)],
    crayons: [
      Color(0xE6C6D9E8),
      Color(0xD9FFFFFF),
      Color(0xE6D7C5E2),
      Color(0xF2E2D9EE),
      Color(0xE69DB7CE),
    ],
  );

  static LogoColors of(Season season) => switch (season) {
    Season.spring => spring,
    Season.summer => summer,
    Season.autumn => autumn,
    Season.winter => winter,
  };

  static LogoColors lerp(LogoColors a, LogoColors b, double t) {
    if (t <= 0) return a;
    if (t >= 1) return b;
    List<Color> l(List<Color> x, List<Color> y) => [
      for (var i = 0; i < x.length; i++) Color.lerp(x[i], y[i], t)!,
    ];
    return LogoColors(
      gradient: l(a.gradient, b.gradient),
      crayons: l(a.crayons, b.crayons),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is LogoColors &&
      _same(other.gradient, gradient) &&
      _same(other.crayons, crayons);

  static bool _same(List<Color> a, List<Color> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(gradient), Object.hashAll(crayons));
}
