import 'package:flutter/material.dart';

/// Meteorological seasons (northern hemisphere), as the launcher icon
/// (`LauncherIcon.kt`).
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

  /// The season's accent colours.
  SeasonAccents accents(Brightness brightness) =>
      brightness == Brightness.light ? _light[this]! : _dark[this]!;
}

/// The accent colours of one season, from the crayon colours of its icon
/// (`assets/branding/icon_<season>.svg`): in light mode deepened so white
/// text reads on them, the containers in the icon's pastels; in dark mode
/// the pastels themselves on deep containers. Paper and ink stay the same
/// all year. Contrasts: `test/core/theme/contrast_test.dart`.
@immutable
class SeasonAccents {
  const SeasonAccents({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.inversePrimary,
    required this.motif,
    required this.washiTape,
    required this.highlight,
  });

  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;

  /// Primary on the inverse surface (snack bars).
  final Color inversePrimary;

  /// The season motif next to titles.
  final Color motif;

  /// Tape holding the polaroids (translucent).
  final Color washiTape;

  /// Background of search hits (translucent).
  final Color highlight;
}

const _light = {
  // Rose and fresh green, buttercup yellow.
  Season.spring: SeasonAccents(
    primary: Color(0xFFA3405F),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFFBE3EA),
    onPrimaryContainer: Color(0xFF4A1427),
    secondary: Color(0xFF4F7535),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFE3EFCB),
    onSecondaryContainer: Color(0xFF1B2A0E),
    tertiary: Color(0xFF80661A),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFFBEDC0),
    onTertiaryContainer: Color(0xFF2C2100),
    inversePrimary: Color(0xFFF4AFC4),
    motif: Color(0xFFA3405F),
    washiTape: Color(0xB3F6B5C9),
    highlight: Color(0x66FBE08F),
  ),
  // Coral and sea green, apricot.
  Season.summer: SeasonAccents(
    primary: Color(0xFFAF4339),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFFFDCCC),
    onPrimaryContainer: Color(0xFF451410),
    secondary: Color(0xFF2A7369),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFD2EEE8),
    onSecondaryContainer: Color(0xFF0C2B26),
    tertiary: Color(0xFF8A5810),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFFFE6BE),
    onTertiaryContainer: Color(0xFF2E1C00),
    inversePrimary: Color(0xFFF9A08F),
    motif: Color(0xFF8A5810),
    washiTape: Color(0xB39FD5CC),
    highlight: Color(0x66FFD45E),
  ),
  // Rust and ochre, brick.
  Season.autumn: SeasonAccents(
    primary: Color(0xFF9A4A2C),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFF5D3B4),
    onPrimaryContainer: Color(0xFF3D1A0B),
    secondary: Color(0xFF7A5A1C),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFF1E0B8),
    onSecondaryContainer: Color(0xFF2A1E04),
    tertiary: Color(0xFF8A3F30),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFF2D2C8),
    onTertiaryContainer: Color(0xFF3A140C),
    inversePrimary: Color(0xFFEDA567),
    motif: Color(0xFF9A4A2C),
    washiTape: Color(0xB3E9A04F),
    highlight: Color(0x66E7BE6A),
  ),
  // Ice blue and lavender, slate.
  Season.winter: SeasonAccents(
    primary: Color(0xFF46668A),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFDCE7F1),
    onPrimaryContainer: Color(0xFF0F2236),
    secondary: Color(0xFF6D5891),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFE9E0F1),
    onSecondaryContainer: Color(0xFF24173A),
    tertiary: Color(0xFF4D6B78),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFDCEAEE),
    onTertiaryContainer: Color(0xFF12262D),
    inversePrimary: Color(0xFFA9C3DC),
    motif: Color(0xFF46668A),
    washiTape: Color(0xB3C6D9E8),
    highlight: Color(0x66D7C5E2),
  ),
};

const _dark = {
  Season.spring: SeasonAccents(
    primary: Color(0xFFF4AFC4),
    onPrimary: Color(0xFF4A1427),
    primaryContainer: Color(0xFF6E2F44),
    onPrimaryContainer: Color(0xFFFFD9E4),
    secondary: Color(0xFFB9D99A),
    onSecondary: Color(0xFF1B2A0E),
    secondaryContainer: Color(0xFF3C5528),
    onSecondaryContainer: Color(0xFFDDEFC8),
    tertiary: Color(0xFFF0D682),
    onTertiary: Color(0xFF2C2100),
    tertiaryContainer: Color(0xFF5A4A12),
    onTertiaryContainer: Color(0xFFFBEDC0),
    inversePrimary: Color(0xFFA3405F),
    motif: Color(0xFFF4AFC4),
    washiTape: Color(0x99F29BB6),
    highlight: Color(0x809C8A3C),
  ),
  Season.summer: SeasonAccents(
    primary: Color(0xFFF9A08F),
    onPrimary: Color(0xFF451410),
    primaryContainer: Color(0xFF6E2D25),
    onPrimaryContainer: Color(0xFFFFDCCC),
    secondary: Color(0xFF9FD5CC),
    onSecondary: Color(0xFF0C2B26),
    secondaryContainer: Color(0xFF245650),
    onSecondaryContainer: Color(0xFFD2EEE8),
    tertiary: Color(0xFFFFC97A),
    onTertiary: Color(0xFF2E1C00),
    tertiaryContainer: Color(0xFF5E3F0E),
    onTertiaryContainer: Color(0xFFFFE6BE),
    inversePrimary: Color(0xFFAF4339),
    motif: Color(0xFFFFC97A),
    washiTape: Color(0x9978BDB2),
    highlight: Color(0x80B8862E),
  ),
  Season.autumn: SeasonAccents(
    primary: Color(0xFFEDA567),
    onPrimary: Color(0xFF3D1A0B),
    primaryContainer: Color(0xFF6B3A1E),
    onPrimaryContainer: Color(0xFFFFDCC0),
    secondary: Color(0xFFE2C27A),
    onSecondary: Color(0xFF2A1E04),
    secondaryContainer: Color(0xFF5A4416),
    onSecondaryContainer: Color(0xFFF6E3B8),
    tertiary: Color(0xFFE79A82),
    onTertiary: Color(0xFF3A140C),
    tertiaryContainer: Color(0xFF6A2E22),
    onTertiaryContainer: Color(0xFFFFDAD0),
    inversePrimary: Color(0xFF9A4A2C),
    motif: Color(0xFFEDA567),
    washiTape: Color(0x99C9935E),
    highlight: Color(0x80B0703A),
  ),
  Season.winter: SeasonAccents(
    primary: Color(0xFFA9C3DC),
    onPrimary: Color(0xFF0F2236),
    primaryContainer: Color(0xFF34506B),
    onPrimaryContainer: Color(0xFFDCE7F1),
    secondary: Color(0xFFCDB9E6),
    onSecondary: Color(0xFF24173A),
    secondaryContainer: Color(0xFF4D3F69),
    onSecondaryContainer: Color(0xFFEDE3F7),
    tertiary: Color(0xFFA8C8D2),
    onTertiary: Color(0xFF12262D),
    tertiaryContainer: Color(0xFF2F4A54),
    onTertiaryContainer: Color(0xFFDCEAEE),
    inversePrimary: Color(0xFF46668A),
    motif: Color(0xFFC6D9E8),
    washiTape: Color(0x999DB7CE),
    highlight: Color(0x80706090),
  ),
};
