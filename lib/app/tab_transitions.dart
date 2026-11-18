import 'package:flutter/material.dart';

/// Duration of a tab change (slide) and of the navigation indicator.
const Duration tabSwitchDuration = Duration(milliseconds: 320);
const Curve tabSwitchCurve = Curves.easeOutCubic;

/// Holds the pages of all tabs and slides between them horizontally, in the
/// direction of the tab order (like turning sideways through a notebook).
///
/// Every tab stays in the tree – scroll positions, search text and other
/// state survive. Only the visible tab ticks and may start hero flights
/// (the same photo can be on several tabs). Each page is a repaint
/// boundary, so sliding only moves layers. With "reduce motion" the switch
/// is instant.
///
/// Swiping between tabs is deliberately not offered: the journal's mood
/// chips and the map scroll horizontally themselves, and Android's back
/// gesture starts at the screen edges.
class SlidingTabStack extends StatefulWidget {
  const SlidingTabStack({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  State<SlidingTabStack> createState() => _SlidingTabStackState();
}

class _SlidingTabStackState extends State<SlidingTabStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: tabSwitchDuration,
    value: 1,
  );
  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: tabSwitchCurve,
  );

  /// The tab that is sliding out, while the animation runs.
  int? _previous;

  /// +1: the new tab comes from the right (it is further right in the
  /// navigation), -1: from the left.
  double _direction = 1;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _previous != null) {
        setState(() => _previous = null);
      }
    });
  }

  @override
  void didUpdateWidget(SlidingTabStack old) {
    super.didUpdateWidget(old);
    if (old.currentIndex == widget.currentIndex) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _previous = null;
      _controller.value = 1;
      return;
    }
    _previous = old.currentIndex;
    _direction = widget.currentIndex > old.currentIndex ? 1 : -1;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.currentIndex;
    final previous = _previous;
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          for (final (i, child) in widget.children.indexed)
            _page(
              index: i,
              visible: i == current || i == previous,
              active: i == current,
              offset: i == current
                  ? Tween<Offset>(
                      begin: Offset(_direction, 0),
                      end: Offset.zero,
                    )
                  : Tween<Offset>(
                      begin: Offset.zero,
                      end: Offset(-_direction, 0),
                    ),
              child: child,
            ),
        ],
      ),
    );
  }

  Widget _page({
    required int index,
    required bool visible,
    required bool active,
    required Tween<Offset> offset,
    required Widget child,
  }) {
    final sliding = _previous != null && visible;
    // The same widget structure in every state: the tab's subtree (and its
    // state) is never rebuilt from scratch because of the animation.
    final page = SlideTransition(
      position: sliding
          ? _progress.drive(offset)
          : const AlwaysStoppedAnimation(Offset.zero),
      child: RepaintBoundary(child: child),
    );
    return Offstage(
      key: ValueKey(index),
      offstage: !visible,
      child: TickerMode(
        enabled: active,
        child: HeroMode(
          enabled: active,
          child: IgnorePointer(ignoring: !active, child: page),
        ),
      ),
    );
  }
}

/// Duration of the title change: striking out the old name, then writing
/// the new one.
const Duration tabTitleDuration = Duration(milliseconds: 460);

/// The app bar title of the tabs: the name of the current tab, optionally
/// followed by [trailing].
///
/// On a tab change the old name is quickly struck through by hand, then the
/// new one is "written" from left to right (revealed behind a soft pen
/// edge) while the struck name fades. The width glides from the old to the
/// new length during the writing, so [trailing] follows the pen instead of
/// jumping. With "reduce motion" the switch is instant.
class TabTitle extends StatefulWidget {
  const TabTitle({
    super.key,
    required this.index,
    required this.title,
    this.trailing,
  });

  /// Index of the current tab – a change starts the transition.
  final int index;
  final String title;
  final Widget? trailing;

  @override
  State<TabTitle> createState() => _TabTitleState();
}

class _TabTitleState extends State<TabTitle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: tabTitleDuration,
    value: 1,
  )..addStatusListener(_onStatus);

  /// The struck-out title while the transition runs.
  String? _previous;

  /// Share of the transition spent striking out the old title.
  static const double _strikeShare = 0.36;

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _previous != null) {
      setState(() => _previous = null);
    }
  }

  @override
  void didUpdateWidget(TabTitle old) {
    super.didUpdateWidget(old);
    if (old.index == widget.index || old.title == widget.title) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _previous = null;
      _controller.value = 1;
      return;
    }
    // Switching again mid-way strikes out whatever is visible now.
    _previous = _controller.isAnimating && _writeT < 0.5
        ? (_previous ?? old.title)
        : old.title;
    _controller.forward(from: 0);
  }

  double get _strikeT => Curves.easeInOut.transform(
    (_controller.value / _strikeShare).clamp(0.0, 1.0),
  );

  double get _writeT => Curves.easeOutCubic.transform(
    ((_controller.value - _strikeShare) / (1 - _strikeShare)).clamp(0.0, 1.0),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Text _text(String title) => Text(
    title,
    maxLines: 1,
    softWrap: false,
    overflow: TextOverflow.ellipsis,
  );

  @override
  Widget build(BuildContext context) {
    final previous = _previous;
    return Row(
      children: [
        Flexible(
          child: previous == null
              ? _text(widget.title)
              : Semantics(
                  label: widget.title,
                  child: ExcludeSemantics(
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) =>
                          _transition(context, previous, widget.title),
                    ),
                  ),
                ),
        ),
        if (widget.trailing case final trailing?) ...[
          const SizedBox(width: 8),
          trailing,
        ],
      ],
    );
  }

  Widget _transition(BuildContext context, String from, String to) {
    final style = DefaultTextStyle.of(context).style;
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    Size sizeOf(String s) => (TextPainter(
      text: TextSpan(text: s, style: style),
      textDirection: direction,
      textScaler: scaler,
      maxLines: 1,
    )..layout()).size;

    final strike = _strikeT;
    final write = _writeT;
    final fromSize = sizeOf(from);
    final toSize = sizeOf(to);
    final width = fromSize.width + (toSize.width - fromSize.width) * write;
    final height = fromSize.height > toSize.height
        ? fromSize.height
        : toSize.height;
    final color = style.color ?? Theme.of(context).colorScheme.onSurface;

    return LayoutBuilder(
      builder: (context, constraints) => ClipRect(
        child: SizedBox(
          width: width.clamp(0.0, constraints.maxWidth),
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // The old name, struck through, fading while the new one is
              // written.
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: fromSize.width,
                child: Opacity(
                  opacity: 1 - write,
                  child: CustomPaint(
                    foregroundPainter: _StrikePainter(
                      progress: strike,
                      color: color,
                    ),
                    child: Center(child: _text(from)),
                  ),
                ),
              ),
              // The new name, revealed left to right behind a soft edge.
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: toSize.width,
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (bounds) {
                    const edge = 14.0;
                    final x = (bounds.width + edge) * write;
                    return LinearGradient(
                      colors: const [Colors.white, Colors.transparent],
                      stops: [
                        ((x - edge) / bounds.width).clamp(0.0, 1.0),
                        (x / bounds.width).clamp(0.0, 1.0),
                      ],
                    ).createShader(Offset.zero & bounds.size);
                  },
                  child: Center(child: _text(to)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A hand-drawn line through a word, drawn from left to right up to
/// [progress] – slightly rising and with a little overshoot at both ends.
class _StrikePainter extends CustomPainter {
  _StrikePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final y = size.height * 0.56;
    final start = Offset(-2, y + 1.5);
    final end = Offset(size.width + 2, y - 2);
    final control = Offset(size.width * 0.5, y + 0.5);
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    final metric = path.computeMetrics().first;
    canvas.drawPath(
      metric.extractPath(0, metric.length * progress),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_StrikePainter old) =>
      old.progress != progress || old.color != color;
}
