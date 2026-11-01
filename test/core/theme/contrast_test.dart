import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/core/theme/app_theme.dart';
import 'package:randnotiz/core/theme/season.dart';

/// WCAG 2.x contrast ratio.
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (max(la, lb) + 0.05) / (min(la, lb) + 0.05);
}

void main() {
  for (final brightness in Brightness.values) {
    for (final season in Season.values) {
      group('${brightness.name} / ${season.name}', () {
        final scheme = brightness == Brightness.light
            ? AppTheme.lightScheme(season)
            : AppTheme.darkScheme(season);
        final diary = AppTheme.diaryColors(brightness, season);

        void expectContrast(String name, Color fg, Color bg, double minimum) {
          final ratio = contrast(fg, bg);
          expect(
            ratio,
            greaterThanOrEqualTo(minimum),
            reason: '$name: ${ratio.toStringAsFixed(2)} < $minimum',
          );
        }

        test('text on surfaces meets WCAG AA (4.5:1)', () {
          for (final bg in [
            scheme.surface,
            scheme.surfaceContainerLowest,
            scheme.surfaceContainerLow,
            scheme.surfaceContainer,
            scheme.surfaceContainerHigh,
            scheme.surfaceContainerHighest,
            diary.paper,
          ]) {
            expectContrast('onSurface', scheme.onSurface, bg, 7);
            expectContrast(
              'onSurfaceVariant',
              scheme.onSurfaceVariant,
              bg,
              4.5,
            );
          }
        });

        test('accent pairs meet WCAG AA (4.5:1)', () {
          expectContrast('primary', scheme.onPrimary, scheme.primary, 4.5);
          expectContrast(
            'primaryContainer',
            scheme.onPrimaryContainer,
            scheme.primaryContainer,
            4.5,
          );
          expectContrast(
            'secondary',
            scheme.onSecondary,
            scheme.secondary,
            4.5,
          );
          expectContrast(
            'secondaryContainer',
            scheme.onSecondaryContainer,
            scheme.secondaryContainer,
            4.5,
          );
          expectContrast('tertiary', scheme.onTertiary, scheme.tertiary, 4.5);
          expectContrast('error', scheme.onError, scheme.error, 4.5);
        });

        test('accents as text/icons on the page background (3:1)', () {
          expectContrast(
            'primary on surface',
            scheme.primary,
            scheme.surface,
            3,
          );
          expectContrast(
            'secondary on surface',
            scheme.secondary,
            scheme.surface,
            3,
          );
          expectContrast('season motif', diary.seasonMotif, scheme.surface, 3);
          expectContrast('outline', scheme.outline, scheme.surface, 3);
        });

        test('note text on the polaroid caption stays readable', () {
          // Captions on the polaroid frame use the dark ink in both modes.
          expectContrast(
            'caption',
            const Color(0xFF3A2A1F),
            diary.polaroidFrame,
            7,
          );
        });
      });
    }
  }

  test('season is derived from the month', () {
    expect(Season.of(DateTime(2026, 3, 1)), Season.spring);
    expect(Season.of(DateTime(2026, 8, 31)), Season.summer);
    expect(Season.of(DateTime(2026, 10, 31)), Season.autumn);
    expect(Season.of(DateTime(2026, 12, 1)), Season.winter);
    expect(Season.of(DateTime(2026, 2, 28)), Season.winter);
  });
}
