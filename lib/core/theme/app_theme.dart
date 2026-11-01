import 'package:flutter/material.dart';

import 'season.dart';

/// Font families bundled as assets (SIL Open Font License).
abstract final class AppFonts {
  /// Handwriting for note text.
  static const handwriting = 'Kalam';

  /// Calm serif for titles.
  static const serif = 'CrimsonText';
}

/// Extra colours that are not part of [ColorScheme].
@immutable
class DiaryColors extends ThemeExtension<DiaryColors> {
  const DiaryColors({
    required this.paper,
    required this.paperSpeckle,
    required this.ruledLine,
    required this.polaroidFrame,
    required this.polaroidShadow,
    required this.washiTape,
    required this.seasonMotif,
    required this.highlight,
  });

  final Color paper;
  final Color paperSpeckle;
  final Color ruledLine;
  final Color polaroidFrame;
  final Color polaroidShadow;
  final Color washiTape;
  final Color seasonMotif;

  /// Background of search hits.
  final Color highlight;

  @override
  DiaryColors copyWith({Color? paper}) => DiaryColors(
    paper: paper ?? this.paper,
    paperSpeckle: paperSpeckle,
    ruledLine: ruledLine,
    polaroidFrame: polaroidFrame,
    polaroidShadow: polaroidShadow,
    washiTape: washiTape,
    seasonMotif: seasonMotif,
    highlight: highlight,
  );

  @override
  DiaryColors lerp(DiaryColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return DiaryColors(
      paper: l(paper, other.paper),
      paperSpeckle: l(paperSpeckle, other.paperSpeckle),
      ruledLine: l(ruledLine, other.ruledLine),
      polaroidFrame: l(polaroidFrame, other.polaroidFrame),
      polaroidShadow: l(polaroidShadow, other.polaroidShadow),
      washiTape: l(washiTape, other.washiTape),
      seasonMotif: l(seasonMotif, other.seasonMotif),
      highlight: l(highlight, other.highlight),
    );
  }
}

extension DiaryThemeX on BuildContext {
  DiaryColors get diary => Theme.of(this).extension<DiaryColors>()!;
}

abstract final class AppTheme {
  static ColorScheme lightScheme(Season season) {
    Color s(Color c) => seasonalShift(c, season);
    return ColorScheme(
      brightness: Brightness.light,
      primary: s(const Color(0xFF8E5523)), // caramel
      onPrimary: Colors.white,
      primaryContainer: s(const Color(0xFFF2DCC2)),
      onPrimaryContainer: const Color(0xFF3B220E),
      secondary: s(const Color(0xFFA9492E)), // terracotta
      onSecondary: Colors.white,
      secondaryContainer: s(const Color(0xFFF6D8CB)),
      onSecondaryContainer: const Color(0xFF431709),
      tertiary: const Color(0xFF56663F),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFDDE5C8),
      onTertiaryContainer: const Color(0xFF1C2410),
      error: const Color(0xFFB3261E),
      onError: Colors.white,
      errorContainer: const Color(0xFFF9DEDC),
      onErrorContainer: const Color(0xFF410E0B),
      surface: const Color(0xFFFBF6EC),
      onSurface: const Color(0xFF3A2A1F),
      onSurfaceVariant: const Color(0xFF66503F),
      surfaceContainerLowest: const Color(0xFFFFFDF8),
      surfaceContainerLow: const Color(0xFFF7F0E2),
      surfaceContainer: const Color(0xFFF3EADA),
      surfaceContainerHigh: const Color(0xFFEEE3CF),
      surfaceContainerHighest: const Color(0xFFE8DBC4),
      outline: const Color(0xFF8F7866),
      outlineVariant: const Color(0xFFDCCBB5),
      shadow: const Color(0xFF3A2A1F),
      scrim: Colors.black,
      inverseSurface: const Color(0xFF3A2E26),
      onInverseSurface: const Color(0xFFF7EEE2),
      inversePrimary: const Color(0xFFE6BD7B),
    );
  }

  static ColorScheme darkScheme(Season season) {
    Color s(Color c) => seasonalShift(c, season);
    return ColorScheme(
      brightness: Brightness.dark,
      primary: s(const Color(0xFFE2BE70)), // muted gold
      onPrimary: const Color(0xFF2E2108),
      primaryContainer: s(const Color(0xFF5B4421)),
      onPrimaryContainer: const Color(0xFFF8E3B8),
      secondary: s(const Color(0xFFE79E82)), // soft terracotta
      onSecondary: const Color(0xFF3B150A),
      secondaryContainer: s(const Color(0xFF6B3626)),
      onSecondaryContainer: const Color(0xFFFFDCCF),
      tertiary: const Color(0xFFBCCB9E),
      onTertiary: const Color(0xFF283214),
      tertiaryContainer: const Color(0xFF3E4A29),
      onTertiaryContainer: const Color(0xFFD9E7BA),
      error: const Color(0xFFF2B8B5),
      onError: const Color(0xFF601410),
      errorContainer: const Color(0xFF8C1D18),
      onErrorContainer: const Color(0xFFF9DEDC),
      surface: const Color(0xFF2B211B), // coffee
      onSurface: const Color(0xFFF2E7D8),
      onSurfaceVariant: const Color(0xFFD5C3AF),
      surfaceContainerLowest: const Color(0xFF221A15),
      surfaceContainerLow: const Color(0xFF30251E),
      surfaceContainer: const Color(0xFF362A22),
      surfaceContainerHigh: const Color(0xFF403229),
      surfaceContainerHighest: const Color(0xFF4A3B30),
      outline: const Color(0xFFA08B79),
      outlineVariant: const Color(0xFF56463B),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: const Color(0xFFF2E7D8),
      onInverseSurface: const Color(0xFF3A2E26),
      inversePrimary: const Color(0xFF8E5523),
    );
  }

  static DiaryColors diaryColors(Brightness brightness, Season season) =>
      brightness == Brightness.light
      ? DiaryColors(
          paper: const Color(0xFFFBF6EC),
          paperSpeckle: const Color(0xFF8A6A4A),
          ruledLine: const Color(0xFFE4D3BA),
          polaroidFrame: const Color(0xFFFFFDF8),
          polaroidShadow: const Color(0x33553A22),
          washiTape: seasonalShift(const Color(0xB3D9A47A), season),
          seasonMotif: season.motifColor(brightness),
          highlight: const Color(0x66E6B35A),
        )
      : DiaryColors(
          paper: const Color(0xFF2B211B),
          paperSpeckle: const Color(0xFFE8D2B0),
          ruledLine: const Color(0xFF4A3A2E),
          polaroidFrame: const Color(0xFFEDE3D1),
          polaroidShadow: const Color(0x66000000),
          washiTape: seasonalShift(const Color(0x99C9935E), season),
          seasonMotif: season.motifColor(brightness),
          highlight: const Color(0x80B8862E),
        );

  static ThemeData build(Brightness brightness, Season season) {
    final scheme = brightness == Brightness.light
        ? lightScheme(season)
        : darkScheme(season);
    final base = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      brightness: brightness,
    );
    final text = base.textTheme;
    TextStyle? serif(TextStyle? s, {FontWeight? weight}) =>
        s?.copyWith(fontFamily: AppFonts.serif, fontWeight: weight);

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      textTheme: text.copyWith(
        displayLarge: serif(text.displayLarge),
        displayMedium: serif(text.displayMedium),
        displaySmall: serif(text.displaySmall),
        headlineLarge: serif(text.headlineLarge, weight: FontWeight.w600),
        headlineMedium: serif(text.headlineMedium, weight: FontWeight.w600),
        headlineSmall: serif(text.headlineSmall, weight: FontWeight.w600),
        titleLarge: serif(
          text.titleLarge,
          weight: FontWeight.w600,
        )?.copyWith(fontSize: 24),
        titleMedium: serif(
          text.titleMedium,
          weight: FontWeight.w600,
        )?.copyWith(fontSize: 18),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.serif,
          fontWeight: FontWeight.w600,
          fontSize: 26,
          color: scheme.onSurface,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        indicatorColor: scheme.primaryContainer,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontFamily: AppFonts.serif,
            fontSize: 14,
            color: scheme.onSurface,
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      extensions: [diaryColors(brightness, season)],
    );
  }

  /// Text style for note text (handwriting).
  static TextStyle noteText(BuildContext context, {double size = 19}) {
    final scheme = Theme.of(context).colorScheme;
    return TextStyle(
      fontFamily: AppFonts.handwriting,
      fontSize: size,
      height: 1.55,
      color: scheme.onSurface,
    );
  }
}
