import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notes/presentation/note_editor_controller.dart';
import 'song_record.dart';

/// The song's record, lying on the lower right corner of the polaroid –
/// fully visible, so the cover on its label can be seen.
///
/// While the polaroid flies in or out (hero flight in the navigator's
/// overlay, above the page) the record stays hidden: anything the page
/// paints during a flight lies *under* the flying polaroid and would jump
/// in front of it when the flight lands. So the record rolls in from the
/// right once the page has fully opened, and rolls out again before the
/// page closes (the pop waits for it).
class RecordOnPolaroid extends ConsumerStatefulWidget {
  const RecordOnPolaroid({
    super.key,
    required this.assetId,
    required this.polaroidWidth,
    required this.child,
  });

  /// Diameter of the record relative to the polaroid's width.
  static const sizeFactor = 0.42;

  /// Part of the record that sticks out beyond the polaroid's right edge.
  static const outside = 0.62;

  /// How far (relative to its diameter) the record rolls in from.
  static const rollDistance = 0.55;

  static const rollIn = Duration(milliseconds: 520);
  static const rollOut = Duration(milliseconds: 240);

  final String assetId;
  final double polaroidWidth;
  final Widget child;

  @override
  ConsumerState<RecordOnPolaroid> createState() => _RecordOnPolaroidState();
}

class _RecordOnPolaroidState extends ConsumerState<RecordOnPolaroid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _roll =
      AnimationController(
        vsync: this,
        duration: RecordOnPolaroid.rollIn,
        reverseDuration: RecordOnPolaroid.rollOut,
      )..addStatusListener((_) {
        // Taps and the pop guard follow the record's state.
        if (mounted) setState(() {});
      });
  Animation<double>? _route;
  bool _hasSong = false;
  bool _reduceMotion = false;
  bool _closing = false;

  bool get _routeSettled =>
      _route == null || _route!.status == AnimationStatus.completed;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context)?.animation;
    if (!identical(route, _route)) {
      _route?.removeStatusListener(_onRouteStatus);
      _route = route?..addStatusListener(_onRouteStatus);
    }
  }

  void _onRouteStatus(AnimationStatus status) {
    if (status == AnimationStatus.reverse && !_closing && !_reduceMotion) {
      // Popped without waiting for the record (e.g. Navigator.pop): it must
      // not be left under the polaroid flying back.
      _roll.value = 0;
    }
    // The page has opened: the record may roll in now.
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _route?.removeStatusListener(_onRouteStatus);
    _roll.dispose();
    super.dispose();
  }

  /// Whether the record should be (or become) visible.
  bool get _wanted => _hasSong && _routeSettled && !_closing;

  bool get _inSync => _wanted
      ? _roll.status == AnimationStatus.forward || _roll.isCompleted
      : _closing || _roll.isDismissed;

  /// Starts rolling in, or hides the record of a removed song. Runs after
  /// the frame: the controller notifies listeners, which rebuild.
  void _sync() {
    if (!mounted || _inSync) return;
    if (!_wanted) {
      _roll.value = 0;
    } else if (_reduceMotion) {
      _roll.value = 1;
    } else {
      unawaited(_roll.forward());
    }
  }

  /// Back gesture, back button or `maybePop`: roll out, then close.
  Future<void> _rollOutAndPop(Object? result) async {
    if (_closing) return;
    setState(() => _closing = true);
    final navigator = Navigator.of(context);
    try {
      await _roll.reverse().orCancel;
    } on TickerCanceled {
      return; // disposed meanwhile
    }
    if (mounted) navigator.pop(result);
  }

  @override
  Widget build(BuildContext context) {
    _hasSong = ref.watch(
      noteEditorProvider(widget.assetId).select((s) => s.song != null),
    );
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (!_inSync) WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
    final hasSong = _hasSong;
    final size = (widget.polaroidWidth * RecordOnPolaroid.sizeFactor).clamp(
      84.0,
      176.0,
    );

    final distance = size * RecordOnPolaroid.rollDistance;
    final record = AnimatedBuilder(
      animation: _roll,
      builder: (context, child) {
        // Rolling, not sliding: the turn matches the distance covered.
        final t = Curves.easeOutCubic.transform(_roll.value);
        final dx = (1 - t) * distance;
        return Opacity(
          opacity: Curves.easeOut.transform(_roll.value),
          child: Transform.translate(
            offset: Offset(dx, 0),
            child: DecoratedBox(
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
              child: Transform.rotate(angle: dx / (size / 2), child: child),
            ),
          ),
        );
      },
      child: SongRecord(assetId: widget.assetId, size: size),
    );

    // The record must lie inside the Stack's box to receive taps (hit tests
    // stop at a box's edge), so the box grows on the right by the part that
    // sticks out. The same structure with and without a song, so the
    // polaroid (and its title field) is never rebuilt from scratch.
    return PopScope(
      // Closing waits for the record to roll out first.
      canPop: !hasSong || _reduceMotion || _roll.isDismissed,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) unawaited(_rollOutAndPop(result));
      },
      child: Stack(
        children: [
          Padding(
            key: const ValueKey('polaroid'),
            padding: EdgeInsets.only(
              right: hasSong ? size * RecordOnPolaroid.outside : 0,
            ),
            child: widget.child,
          ),
          // Above the polaroid: lying on its corner, over the rim's end.
          if (hasSong)
            Positioned(
              right: 0,
              bottom: widget.polaroidWidth * 0.03,
              child: IgnorePointer(ignoring: !_roll.isCompleted, child: record),
            ),
        ],
      ),
    );
  }
}
