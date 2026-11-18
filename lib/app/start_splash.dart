import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/logo_colors.dart';
import '../core/widgets/app_logo.dart';
import '../core/widgets/paper.dart';
import '../l10n/generated/app_localizations.dart';

/// The first moment after Android's start screen. The logo stays exactly
/// where the system drew it (same size, same place – nothing jumps), the
/// name and the claim appear beneath it, then everything fades and reveals
/// the app (or the introduction). Plays once per process start; with
/// "reduce motion" it only fades.
///
/// One controller drives everything, so it takes the same time on every
/// device and never waits for anything.
class StartSplash extends StatefulWidget {
  const StartSplash({super.key, required this.child});

  final Widget child;

  /// The whole sequence.
  static const duration = Duration(milliseconds: 1500);

  /// Size of the logo's box: Android's splash icon (288 dp, see
  /// `res/drawable/splash_logo.xml`).
  static const logoBox = 288.0;

  /// Whether the start screen still covers [context]'s screen – e.g. the
  /// introduction waits with its own entrance until it is gone. False
  /// outside a [StartSplash] (tests, replaying the introduction).
  static bool coversOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_SplashScope>()
          ?.notifier
          ?.value ??
      false;

  @override
  State<StartSplash> createState() => _StartSplashState();
}

class _StartSplashState extends State<StartSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: StartSplash.duration,
  );
  bool _done = false;
  final _covers = ValueNotifier(true);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_clock.isAnimating || _done || _clock.value > 0) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _clock.duration = const Duration(milliseconds: 250);
    }
    _clock.forward().whenCompleteOrCancel(() {
      _covers.value = false;
      if (mounted) setState(() => _done = true);
    });
  }

  @override
  void dispose() {
    _clock.dispose();
    _covers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Always the same tree around the app, so nothing below is rebuilt
    // from scratch when the start screen leaves.
    final child = _SplashScope(notifier: _covers, child: widget.child);
    if (_done) {
      return Stack(fit: StackFit.expand, children: [child]);
    }
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final words = CurvedAnimation(
      parent: _clock,
      curve: reduceMotion
          ? const Threshold(0)
          : const Interval(0.08, 0.4, curve: Curves.easeOutCubic),
    );
    // Android draws the standard logo; it takes on the season's colours.
    final recolour = CurvedAnimation(
      parent: _clock,
      curve: reduceMotion
          ? const Threshold(0)
          : const Interval(0, 0.4, curve: Curves.easeInOut),
    );
    final leave = CurvedAnimation(
      parent: _clock,
      curve: reduceMotion
          ? Curves.easeOut
          : const Interval(0.72, 1, curve: Curves.easeInOut),
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        // Catches taps until it is gone.
        AbsorbPointer(
          child: AnimatedBuilder(
            animation: leave,
            builder: (context, child) => Opacity(
              opacity: 1 - leave.value,
              child: Transform.scale(
                scale: 1 + 0.04 * leave.value,
                child: child,
              ),
            ),
            child: _SplashFace(words: words, recolour: recolour),
          ),
        ),
      ],
    );
  }
}

class _SplashScope extends InheritedNotifier<ValueNotifier<bool>> {
  const _SplashScope({required super.notifier, required super.child});
}

class _SplashFace extends StatelessWidget {
  const _SplashFace({required this.words, required this.recolour});

  final Animation<double> words;
  final Animation<double> recolour;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      child: PaperBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // The drawing reaches about 23 % of the box below the centre
            // (its flourish); the words start a little below that.
            final center = constraints.maxHeight / 2;
            final below = center + StartSplash.logoBox * 0.3;
            return Stack(
              children: [
                Center(
                  child: ExcludeSemantics(
                    child: AnimatedBuilder(
                      animation: recolour,
                      builder: (context, _) => AppLogo(
                        size: StartSplash.logoBox,
                        colors: LogoColors.lerp(
                          LogoColors.standard,
                          context.diary.logo,
                          recolour.value,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 32,
                  right: 32,
                  top: below,
                  child: AnimatedBuilder(
                    animation: words,
                    builder: (context, child) => Opacity(
                      opacity: words.value,
                      child: Transform.translate(
                        offset: Offset(0, 10 * (1 - words.value)),
                        child: child,
                      ),
                    ),
                    child: MediaQuery.withClampedTextScaling(
                      maxScaleFactor: 1.3,
                      child: Column(
                        children: [
                          Text(
                            l10n.appTitle,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontFamily: AppFonts.serif,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l10n.claim,
                            textAlign: TextAlign.center,
                            style: AppTheme.noteText(context, size: 18)
                                .copyWith(
                                  color: scheme.onSurfaceVariant,
                                  height: 1.35,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
