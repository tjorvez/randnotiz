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

/// The app bar title of the tabs: the name of the current tab followed by
/// [trailing] (the seasonal motif).
///
/// On a tab change the old name slides out and the new one slides in, in
/// the direction of the tab order (like the pages, see [SlidingTabStack]).
/// The width of the title glides from the old to the new length, so
/// [trailing] moves along smoothly instead of jumping. With "reduce
/// motion" the switch is instant.
class TabTitle extends StatefulWidget {
  const TabTitle({
    super.key,
    required this.index,
    required this.title,
    required this.trailing,
  });

  /// Index of the current tab – a change starts the transition.
  final int index;
  final String title;
  final Widget trailing;

  @override
  State<TabTitle> createState() => _TabTitleState();
}

class _TabTitleState extends State<TabTitle> {
  /// +1: the new title comes from the right, -1: from the left.
  double _direction = 1;

  /// How far (relative to its own width) a title slides.
  static const double _shift = 0.25;

  @override
  void didUpdateWidget(TabTitle old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) {
      _direction = widget.index > old.index ? 1 : -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion ? Duration.zero : tabSwitchDuration;
    final currentKey = ValueKey(widget.index);
    final switcher = AnimatedSwitcher(
      duration: duration,
      switchInCurve: tabSwitchCurve,
      switchOutCurve: tabSwitchCurve,
      // Only the current title determines the size; outgoing ones
      // are laid over it (and clipped by the AnimatedSize), so the
      // width moves from the old length straight to the new one.
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.centerLeft,
        children: [
          for (final child in previous)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: 1,
                child: child,
              ),
            ),
          ?current,
        ],
      ),
      transitionBuilder: (child, animation) {
        final incoming = child.key == currentKey;
        final from = Offset((incoming ? _shift : -_shift) * _direction, 0);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(begin: from, end: Offset.zero).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        widget.title,
        key: currentKey,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
    );
    return Row(
      children: [
        Flexible(
          // AnimatedSize must not run with a zero duration (it re-dirties
          // itself during layout), so "reduce motion" leaves it out.
          child: reduceMotion
              ? switcher
              : AnimatedSize(
                  duration: duration,
                  curve: tabSwitchCurve,
                  alignment: Alignment.centerLeft,
                  child: switcher,
                ),
        ),
        const SizedBox(width: 8),
        widget.trailing,
      ],
    );
  }
}
