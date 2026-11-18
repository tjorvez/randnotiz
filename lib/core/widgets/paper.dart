import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Cream (or coffee) paper with a very light, static speckle texture.
///
/// The texture is painted once at screen size in its own layer, whatever
/// size the paper currently has: when the keyboard slides in and the page
/// shrinks frame by frame, the thousands of specks are not redrawn – the
/// layer is just clipped.
class PaperBackground extends StatelessWidget {
  const PaperBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final diary = context.diary;
    final screen = MediaQuery.sizeOf(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: diary.paper),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned(
            left: 0,
            top: 0,
            width: screen.width,
            height: screen.height,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _PaperTexturePainter(diary.paperSpeckle),
                isComplex: true,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _PaperTexturePainter extends CustomPainter {
  _PaperTexturePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(7);
    final speck = Paint()..color = color.withValues(alpha: 0.035);
    final fiber = Paint()
      ..color = color.withValues(alpha: 0.025)
      ..strokeWidth = 0.6;
    final area = size.width * size.height;
    final specks = (area / 900).clamp(0, 4000).toInt();
    for (var i = 0; i < specks; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        random.nextDouble() * 0.9 + 0.2,
        speck,
      );
    }
    final fibers = (area / 12000).clamp(0, 400).toInt();
    for (var i = 0; i < fibers; i++) {
      final start = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      final angle = random.nextDouble() * pi;
      final length = 4 + random.nextDouble() * 10;
      canvas.drawLine(
        start,
        start + Offset(cos(angle) * length, sin(angle) * length),
        fiber,
      );
    }
  }

  @override
  bool shouldRepaint(_PaperTexturePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Horizontal ruled lines like in a notebook, aligned to [lineHeight].
class RuledLines extends StatelessWidget {
  const RuledLines({
    super.key,
    required this.lineHeight,
    required this.child,
    this.topOffset = 0,
  });

  final double lineHeight;
  final double topOffset;
  final Widget child;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _RuledPainter(context.diary.ruledLine, lineHeight, topOffset),
    child: child,
  );
}

class _RuledPainter extends CustomPainter {
  _RuledPainter(this.color, this.lineHeight, this.topOffset);

  final Color color;
  final double lineHeight;
  final double topOffset;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    // Each line sits a little above the bottom of its text line, i.e. just
    // under the baseline, like on real ruled paper.
    final lift = lineHeight * 0.12;
    for (
      var y = topOffset + lineHeight - lift;
      y < size.height;
      y += lineHeight
    ) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_RuledPainter old) =>
      old.color != color ||
      old.lineHeight != lineHeight ||
      old.topOffset != topOffset;
}
