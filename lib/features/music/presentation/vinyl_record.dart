import 'dart:math';

import 'package:flutter/material.dart';

/// A small vinyl record: grooves, a soft sheen and the cover as its label.
/// It turns (33⅓ rpm) while [spinning]; with "reduce motion" it stands
/// still. [empty] draws it pale with a plus sign – "add a song".
class VinylRecord extends StatefulWidget {
  const VinylRecord({
    super.key,
    required this.size,
    this.cover,
    this.spinning = false,
    this.empty = false,
  });

  final double size;

  /// The label in the middle (usually the album cover).
  final ImageProvider? cover;
  final bool spinning;
  final bool empty;

  /// One turn at 33⅓ revolutions per minute.
  static const turn = Duration(milliseconds: 1800);

  @override
  State<VinylRecord> createState() => _VinylRecordState();
}

class _VinylRecordState extends State<VinylRecord>
    with SingleTickerProviderStateMixin {
  late final AnimationController _turn = AnimationController(
    vsync: this,
    duration: VinylRecord.turn,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(VinylRecord old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final spin = widget.spinning && !MediaQuery.disableAnimationsOf(context);
    if (spin && !_turn.isAnimating) {
      _turn.repeat();
    } else if (!spin && _turn.isAnimating) {
      // Comes to rest where it is (like lifting the needle).
      _turn.stop();
    }
  }

  @override
  void dispose() {
    _turn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final scheme = Theme.of(context).colorScheme;
    // A large label: it shows the album cover.
    final labelSize = size * 0.5;
    final cover = widget.cover;
    final disc = Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: Size.square(size),
          painter: _DiscPainter(empty: widget.empty),
        ),
        ClipOval(
          child: SizedBox.square(
            dimension: labelSize,
            child: cover != null && !widget.empty
                ? Image(
                    image: cover,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    errorBuilder: (_, _, _) =>
                        ColoredBox(color: scheme.tertiaryContainer),
                  )
                : ColoredBox(
                    color: widget.empty
                        ? scheme.surfaceContainerHighest
                        : scheme.tertiaryContainer,
                  ),
          ),
        ),
        // The spindle hole.
        Container(
          width: size * 0.045,
          height: size * 0.045,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: scheme.surface,
          ),
        ),
      ],
    );
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // A separate layer: turning only rotates it, nothing is repainted.
          RepaintBoundary(
            child: RotationTransition(turns: _turn, child: disc),
          ),
          // The sheen stays put while the disc turns underneath.
          IgnorePointer(
            child: CustomPaint(
              size: Size.square(size),
              painter: _SheenPainter(empty: widget.empty),
            ),
          ),
          if (widget.empty)
            Icon(Icons.add, size: size * 0.24, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _DiscPainter extends CustomPainter {
  const _DiscPainter({required this.empty});

  final bool empty;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final base = empty ? const Color(0xFF9A948C) : const Color(0xFF141414);
    final rect = Rect.fromCircle(center: center, radius: r);
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Color.lerp(base, Colors.white, 0.08)!,
            base,
            Color.lerp(base, Colors.black, 0.25)!,
          ],
          stops: const [0.25, 0.8, 1],
        ).createShader(rect),
    );
    // Grooves: fine rings between the label and the rim.
    final groove = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(0.6, r * 0.008)
      ..color = Colors.white.withValues(alpha: empty ? 0.10 : 0.07);
    for (var f = 0.24; f < 0.96; f += 0.045) {
      canvas.drawCircle(center, r * f, groove);
    }
    // A slightly lighter lead-in groove makes the turning visible.
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r * 0.9),
      -0.4,
      0.9,
      false,
      groove..color = Colors.white.withValues(alpha: 0.14),
    );
  }

  @override
  bool shouldRepaint(_DiscPainter old) => old.empty != empty;
}

class _SheenPainter extends CustomPainter {
  const _SheenPainter({required this.empty});

  final bool empty;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final rect = Rect.fromCircle(center: center, radius: r * 0.97);
    final sheen = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: empty ? 0.10 : 0.16),
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: empty ? 0.06 : 0.10),
          Colors.white.withValues(alpha: 0),
        ],
        stops: const [0.05, 0.13, 0.22, 0.55, 0.63, 0.72],
      ).createShader(rect);
    canvas.drawCircle(center, r * 0.97, sheen);
  }

  @override
  bool shouldRepaint(_SheenPainter old) => old.empty != empty;
}
