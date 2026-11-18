import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/logo_colors.dart';

/// The Randnotiz logo: a photo coloured in with crayon, framed by a
/// hand-drawn line that runs on into a little flourish – the note in the
/// margin. Drawn as vectors after `assets/branding/icon_standard.svg`
/// (without the tile), so it is sharp at every size. The drawing fills about
/// the middle half of [size], like the start screen icon
/// (`res/drawable/splash_logo.xml`, made by `tools/build_icons.py`).
///
/// The photo is coloured like the season's launcher icon (from the theme,
/// [DiaryColors.logo]); the line is brown on light paper and cream on dark
/// paper.
///
/// [drawn] (0…1) draws it as if by hand: the line, then the colours.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 64, this.drawn = 1, this.colors});

  final double size;
  final double drawn;

  /// Instead of the season's colours from the theme.
  final LogoColors? colors;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Randnotiz',
    image: true,
    child: CustomPaint(
      size: Size.square(size),
      painter: LogoPainter(
        colors:
            colors ??
            Theme.of(context).extension<DiaryColors>()?.logo ??
            LogoColors.standard,
        line: Theme.of(context).brightness == Brightness.dark
            ? LogoPainter.lineOnDark
            : LogoPainter.lineOnLight,
        drawn: drawn,
      ),
    ),
  );
}

/// Paints the logo into a square on the icon's 1024-unit grid.
class LogoPainter extends CustomPainter {
  LogoPainter({
    this.colors = LogoColors.standard,
    required this.line,
    this.drawn = 1,
  });

  final LogoColors colors;
  final Color line;
  final double drawn;

  /// The line colours, as `@color/logo_line` (light and night).
  static const lineOnLight = Color(0xFF6E4B36);
  static const lineOnDark = Color(0xFFF2E7D8);

  static const _grid = 1024.0;

  /// The icon's grid scaled down like the start screen icon (whose drawing
  /// must fit a circle of 2/3 of its box).
  static const _scale = 0.8;

  static final _photo = _parse(
    'M300 228 L720 226 L719 606 C719 634 704 650 674 650 L300 650 Z',
  );
  static const _gradientFrom = Offset(300, 226);
  static const _gradientTo = Offset(720, 650);

  /// Crayon strokes inside the photo, in the order of [LogoColors.crayons]:
  /// path and width.
  static final List<(Path, double)> _crayons = [
    (
      _parse(
        'M744 351 Q505 195 250 45 Q466 237 698 422 Q436 242 178 79 '
        'Q444 311 684 525 Q424 359 186 186 Q388 388 587 556 '
        'Q359 377 111 216 Q338 394 523 606',
      ),
      44,
    ),
    (
      _parse(
        'M698 612 Q640 412 544 181 Q575 418 617 665 Q487 449 398 218 '
        'Q419 430 486 687',
      ),
      30,
    ),
    (
      _parse(
        'M816 313 Q542 439 301 586 Q564 513 837 406 Q576 536 352 669 '
        'Q613 582 869 462 Q623 615 348 737 Q614 626 899 523 '
        'Q648 672 410 786',
      ),
      42,
    ),
    (
      _parse(
        'M746 235 Q649 223 574 233 Q670 260 775 301 Q675 285 556 289 '
        'Q646 347 763 379',
      ),
      26,
    ),
    (
      _parse(
        'M472 601 Q416 549 342 485 Q379 571 430 657 Q358 574 293 518 '
        'Q340 613 413 721',
      ),
      24,
    ),
  ];

  /// The frame and the flourish, one stroke.
  static final _line = _parse(
    'M727 626 C733 560 720 500 729 430 C737 360 722 320 731 262 '
    'C734 232 728 218 708 217 C640 212 600 224 520 219 '
    'C440 214 380 226 318 215 C298 212 288 226 290 248 '
    'C294 330 283 400 291 470 C298 540 286 590 292 632 '
    'C294 652 304 660 324 658 C390 654 450 666 520 659 '
    'C586 653 628 700 610 748 C596 790 540 790 552 750 '
    'C566 710 640 716 676 752 C704 780 744 780 772 750 '
    'C786 734 798 722 812 716',
  );

  /// Absolute M, L, Q, C and Z – all the SVG uses.
  static Path _parse(String d) {
    final tokens = RegExp(r'[A-Za-z]|-?\d+(?:\.\d+)?')
        .allMatches(d)
        .map((m) => m[0]!)
        .toList();
    final path = Path();
    var i = 0;
    double n() => double.parse(tokens[i++]);
    var command = 'M';
    while (i < tokens.length) {
      if (RegExp('[A-Za-z]').hasMatch(tokens[i])) command = tokens[i++];
      switch (command) {
        case 'M':
          path.moveTo(n(), n());
          command = 'L';
        case 'L':
          path.lineTo(n(), n());
        case 'Q':
          path.quadraticBezierTo(n(), n(), n(), n());
        case 'C':
          path.cubicTo(n(), n(), n(), n(), n(), n());
        case 'Z':
          path.close();
        default:
          throw ArgumentError('Unsupported path command $command');
      }
    }
    return path;
  }

  /// Progress of a part of the drawing that runs from [start] to [end].
  double _part(double start, double end) =>
      ((drawn - start) / (end - start)).clamp(0.0, 1.0);

  static void _drawPart(Canvas canvas, Path path, Paint paint, double t) {
    if (t == 0) return;
    if (t == 1) {
      canvas.drawPath(path, paint);
      return;
    }
    for (final metric in path.computeMetrics()) {
      canvas.drawPath(metric.extractPath(0, metric.length * t), paint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    canvas
      ..save()
      ..translate((size.width - side) / 2, (size.height - side) / 2)
      ..scale(side / _grid)
      ..translate(_grid / 2, _grid / 2)
      ..scale(_scale)
      ..translate(-_grid / 2, -_grid / 2)
      // As in the SVG: the drawing sits a little left of and below centre.
      ..translate(-38, 12);

    final fill = _part(0.3, 0.6);
    if (fill > 0) {
      canvas.drawPath(
        _photo,
        Paint()
          ..shader = ui.Gradient.linear(
            _gradientFrom,
            _gradientTo,
            colors.gradient,
          )
          ..color = Color.fromRGBO(0, 0, 0, fill),
      );
    }

    canvas
      ..save()
      ..clipPath(_photo);
    for (var i = 0; i < _crayons.length; i++) {
      final (path, width) = _crayons[i];
      final color = colors.crayons[i];
      final start = 0.4 + 0.1 * i;
      _drawPart(
        canvas,
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
        _part(start, start + 0.2),
      );
    }
    canvas.restore();

    _drawPart(
      canvas,
      _line,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 34
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
      _part(0, 0.55),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(LogoPainter old) =>
      old.colors != colors || old.line != line || old.drawn != drawn;
}
