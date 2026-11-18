import 'package:flutter/material.dart';

/// Rolls a round [child] (the record of a note's song) in from the right
/// once its page has fully opened, and out again when the page closes.
///
/// It waits for the page's transition to finish: while the polaroid flies
/// in (a Hero above the page), anything on the page lies below it – the
/// record would first sit behind the polaroid and then jump in front.
/// A song linked while the page is open rolls in right away. With "reduce
/// motion" the record simply is there.
class RecordRoll extends StatefulWidget {
  const RecordRoll({super.key, required this.size, required this.child});

  /// Diameter of the record (rolling turns it by distance / radius).
  final double size;
  final Widget child;

  /// Distance rolled, relative to [size].
  static const distance = 0.9;

  static const rollIn = Duration(milliseconds: 650);
  static const rollOut = Duration(milliseconds: 240);

  @override
  State<RecordRoll> createState() => _RecordRollState();
}

class _RecordRollState extends State<RecordRoll>
    with SingleTickerProviderStateMixin {
  late final AnimationController _roll = AnimationController(
    vsync: this,
    duration: RecordRoll.rollIn,
    reverseDuration: RecordRoll.rollOut,
  );
  late final Animation<double> _t = CurvedAnimation(
    parent: _roll,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  Animation<double>? _route;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context)?.animation;
    if (route != _route) {
      _route?.removeStatusListener(_onRouteStatus);
      _route = route;
      route?.addStatusListener(_onRouteStatus);
    }
    if (MediaQuery.disableAnimationsOf(context)) {
      _roll.value = 1;
    } else if (_roll.isDismissed) {
      // Decided after the first frame: while a page is being pushed, its
      // animation reports "completed" until its transition has started.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final route = _route;
        if (mounted &&
            _roll.isDismissed &&
            (route == null || route.status == AnimationStatus.completed)) {
          _roll.forward();
        }
      });
    }
  }

  void _onRouteStatus(AnimationStatus status) {
    if (MediaQuery.disableAnimationsOf(context)) return;
    switch (status) {
      case AnimationStatus.completed:
        _roll.forward();
      case AnimationStatus.reverse:
        _roll.reverse();
      case AnimationStatus.forward || AnimationStatus.dismissed:
        break;
    }
  }

  @override
  void dispose() {
    _route?.removeStatusListener(_onRouteStatus);
    _roll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _t,
    child: widget.child,
    builder: (context, child) {
      final t = _t.value;
      if (t == 0) return Opacity(opacity: 0, child: child);
      final dx = (1 - t) * widget.size * RecordRoll.distance;
      return Opacity(
        // Mostly there before it has rolled far: no hard edge appearing.
        opacity: (t / 0.35).clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(dx, 0),
          child: DecoratedBox(
            // The shadow does not turn with the record.
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x59000000),
                  blurRadius: 10,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            // Rolling to the left turns it anticlockwise: angle = way / r.
            child: Transform.rotate(
              angle: dx / (widget.size / 2),
              child: child,
            ),
          ),
        ),
      );
    },
  );
}
