import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/format/formatters.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/paper.dart';
import '../../../core/widgets/polaroid.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../music/presentation/vinyl_record.dart';

/// The little animations of the introduction's tour: a sample entry
/// ("Picnic by the lake") going through the app, built from the app's own
/// pieces (polaroid, paper, handwriting, record).
///
/// Each scene plays once whenever its page comes into view and then rests
/// on its last frame; pages out of view wait at the first frame. With
/// "reduce motion" a scene shows its last frame straight away. Scenes are
/// illustrations: drawn on a fixed canvas that scales with the space, not
/// with the font size, and hidden from screen readers (the page's text
/// says the same).
enum IntroScene { photo, write, journal, memories }

class IntroSceneView extends StatefulWidget {
  const IntroSceneView({
    super.key,
    required this.scene,
    required this.active,
    required this.today,
  });

  final IntroScene scene;

  /// Whether the scene's page is the current one.
  final bool active;

  /// For the dates in the scenes.
  final DateTime today;

  /// The design canvas; scaled down to fit narrower pages.
  static const canvas = Size(320, 236);

  static Duration durationOf(IntroScene scene) => switch (scene) {
    IntroScene.photo => const Duration(milliseconds: 2400),
    IntroScene.write => const Duration(milliseconds: 4600),
    IntroScene.journal => const Duration(milliseconds: 3200),
    IntroScene.memories => const Duration(milliseconds: 3000),
  };

  @override
  State<IntroSceneView> createState() => _IntroSceneViewState();
}

class _IntroSceneViewState extends State<IntroSceneView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _t = AnimationController(
    vsync: this,
    duration: IntroSceneView.durationOf(widget.scene),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync(restart: false);
  }

  @override
  void didUpdateWidget(IntroSceneView old) {
    super.didUpdateWidget(old);
    _sync(restart: widget.active && !old.active);
  }

  void _sync({required bool restart}) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _t.value = 1;
    } else if (!widget.active) {
      _t.value = 0;
    } else if (restart || _t.value == 0) {
      _t.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scene = switch (widget.scene) {
      IntroScene.photo => _PhotoScene(t: _t, l10n: l10n),
      IntroScene.write => _WriteScene(t: _t, l10n: l10n, today: widget.today),
      IntroScene.journal => _JournalScene(
        t: _t,
        l10n: l10n,
        today: widget.today,
      ),
      IntroScene.memories => _MemoriesScene(t: _t, l10n: l10n),
    };
    return ExcludeSemantics(
      child: MediaQuery.withNoTextScaling(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = min(
              constraints.maxWidth,
              IntroSceneView.canvas.width * 1.15,
            );
            final scale = width / IntroSceneView.canvas.width;
            return Center(
              child: SizedBox(
                width: width,
                height: IntroSceneView.canvas.height * scale,
                child: FittedBox(
                  child: SizedBox.fromSize(
                    size: IntroSceneView.canvas,
                    child: scene,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 0…1 within [begin]…[end] of the scene's time, eased.
double _phase(
  double t,
  double begin,
  double end, [
  Curve curve = Curves.easeOutCubic,
]) => curve.transform(((t - begin) / (end - begin)).clamp(0.0, 1.0));

// --- 1: a photo becomes an entry ------------------------------------------

/// The navigation pill with the "new entry" button is tapped; the picked
/// photo rises from it and lands as a polaroid with tape.
class _PhotoScene extends AnimatedWidget {
  const _PhotoScene({required Animation<double> t, required this.l10n})
    : super(listenable: t);

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final t = (listenable as Animation<double>).value;
    final scheme = Theme.of(context).colorScheme;
    final tap = _phase(t, 0.05, 0.32, Curves.easeOut);
    final rise = _phase(t, 0.3, 0.85, Curves.easeOutBack);
    final show = _phase(t, 0.3, 0.5);
    const pillTop = 184.0;
    const plusCenter = Offset(232, pillTop + 25);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // The picked photo, flying from the "+" to its place.
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: 176,
          child: Opacity(
            opacity: show,
            child: Transform.translate(
              offset: Offset.lerp(
                plusCenter - const Offset(160, 88),
                Offset.zero,
                rise,
              )!,
              child: Transform.scale(
                scale: 0.2 + 0.8 * rise,
                child: Center(
                  child: SizedBox(
                    width: 132,
                    child: Polaroid(
                      image: const ScenePhoto(ScenePhotoKind.lake),
                      title: l10n.introDemoTitle,
                      tilt: -3 * rise,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // The navigation pill as in the app: three tabs, divider, "+".
        Positioned(
          left: 0,
          right: 0,
          top: pillTop,
          child: Center(
            child: _MiniPill(scheme: scheme, pressed: tap),
          ),
        ),
        // The finger's tap: a ring that widens and fades.
        if (tap > 0 && tap < 1)
          Positioned(
            left: plusCenter.dx - 30,
            top: plusCenter.dy - 30,
            width: 60,
            height: 60,
            child: Opacity(
              opacity: (1 - tap) * 0.8,
              child: Transform.scale(
                scale: 0.4 + 0.8 * tap,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: scheme.primary, width: 3),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.scheme, required this.pressed});

  final ColorScheme scheme;

  /// 0…1: the "+" lights up while it is tapped.
  final double pressed;

  @override
  Widget build(BuildContext context) {
    Widget item(IconData icon, {bool selected = false}) => Container(
      width: 46,
      height: 40,
      decoration: selected
          ? ShapeDecoration(
              shape: const StadiumBorder(),
              color: scheme.primaryContainer,
            )
          : null,
      child: Icon(
        icon,
        size: 20,
        color: selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
      ),
    );
    final glow = sin(pressed * pi);
    return Material(
      color: scheme.surfaceContainerHigh,
      elevation: 5,
      shadowColor: scheme.shadow.withValues(alpha: 0.35),
      shape: StadiumBorder(
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            item(Icons.menu_book, selected: true),
            item(Icons.collections_bookmark_outlined),
            item(Icons.history_edu_outlined),
            SizedBox(
              width: 9,
              height: 24,
              child: Center(
                child: SizedBox(
                  width: 1,
                  height: 24,
                  child: ColoredBox(color: scheme.outlineVariant),
                ),
              ),
            ),
            Container(
              width: 46,
              height: 40,
              decoration: ShapeDecoration(
                shape: const StadiumBorder(),
                color: scheme.primary.withValues(alpha: 0.18 * glow),
              ),
              child: Transform.scale(
                scale: 1 + 0.15 * glow,
                child: Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 20,
                  color: scheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 2: writing in the margin ---------------------------------------------

/// The note page: date, place and weather appear, a mood pops up, the text
/// writes itself (the microphone pulses: dictation works too), and at the
/// end a record rolls onto the polaroid's corner.
class _WriteScene extends AnimatedWidget {
  const _WriteScene({
    required Animation<double> t,
    required this.l10n,
    required this.today,
  }) : super(listenable: t);

  final AppLocalizations l10n;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final t = (listenable as Animation<double>).value;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final meta = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
      fontSize: 12,
    );

    final date = _phase(t, 0.02, 0.12);
    final place = _phase(t, 0.08, 0.18);
    final weather = _phase(t, 0.14, 0.24);
    final mood = _phase(t, 0.2, 0.32, Curves.elasticOut);
    final writing = _phase(t, 0.26, 0.78, Curves.linear);
    final record = _phase(t, 0.8, 0.97, Curves.easeOutCubic);
    final listening = t > 0.26 && t < 0.78;

    final text = l10n.introDemoText;
    final shown = text.substring(0, (text.length * writing).round());

    Widget fade(double v, Widget child) => Opacity(
      opacity: v,
      child: Transform.translate(offset: Offset(0, 6 * (1 - v)), child: child),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outlineVariant),
          borderRadius: BorderRadius.circular(10),
        ),
        child: PaperBackground(
          child: Stack(
            children: [
              Positioned(
                left: 14,
                top: 12,
                width: 104,
                child: Polaroid(
                  image: const ScenePhoto(ScenePhotoKind.lake),
                  title: l10n.introDemoTitle,
                  tilt: -2,
                ),
              ),
              // The record rolls in from the right and settles on the
              // polaroid's corner, turning while it moves.
              Positioned(
                left: 90 + 240 * (1 - record),
                top: 92,
                child: Opacity(
                  opacity: record > 0 ? 1 : 0,
                  child: Transform.rotate(
                    angle: -(1 - record) * 4 * pi,
                    child: VinylRecord(size: 44, spinning: t > 0.8 && t < 1),
                  ),
                ),
              ),
              Positioned(
                left: 134,
                right: 12,
                top: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    fade(date, Text(Fmt.longDate(today), style: meta)),
                    const SizedBox(height: 4),
                    fade(
                      place,
                      Row(
                        children: [
                          Icon(
                            Icons.place_outlined,
                            size: 14,
                            color: meta?.color,
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              l10n.introDemoPlace,
                              style: meta,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    fade(
                      weather,
                      Row(
                        children: [
                          Icon(
                            Icons.wb_sunny_outlined,
                            size: 14,
                            color: meta?.color,
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              '${l10n.weatherKind('clear')}, '
                              '${l10n.weatherTemperature(Fmt.temperature(24))}',
                              style: meta,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Transform.scale(
                      scale: mood,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '😊 🍓',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Lined paper with the handwriting.
              Positioned(
                left: 0,
                right: 0,
                top: 146,
                bottom: 0,
                child: RuledLines(
                  lineHeight: 26,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 48, 0),
                    child: Text(
                      shown,
                      maxLines: 3,
                      overflow: TextOverflow.clip,
                      style: AppTheme.noteText(
                        context,
                        size: 15,
                      ).copyWith(height: 26 / 15),
                    ),
                  ),
                ),
              ),
              // The microphone: pulses while the words appear.
              Positioned(
                right: 10,
                bottom: 10,
                child: _Pulse(
                  active: listening,
                  phase: t,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: listening
                          ? scheme.primary
                          : scheme.surfaceContainerHigh,
                    ),
                    child: Icon(
                      Icons.mic_none,
                      size: 18,
                      color: listening ? scheme.onPrimary : scheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A soft ring around [child] while [active].
class _Pulse extends StatelessWidget {
  const _Pulse({
    required this.active,
    required this.phase,
    required this.child,
  });

  final bool active;
  final double phase;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!active) return child;
    final wave = (phase * 9) % 1;
    final color = Theme.of(context).colorScheme.primary;
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Transform.scale(
          scale: 1 + 0.6 * wave,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.3 * (1 - wave)),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

// --- 3: the journal --------------------------------------------------------

/// Three notebook pages; a search word is typed and the matching entry
/// stands out.
class _JournalScene extends AnimatedWidget {
  const _JournalScene({
    required Animation<double> t,
    required this.l10n,
    required this.today,
  }) : super(listenable: t);

  final AppLocalizations l10n;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final t = (listenable as Animation<double>).value;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final pages = _phase(t, 0, 0.3);
    final typing = _phase(t, 0.3, 0.6, Curves.linear);
    final filter = _phase(t, 0.62, 0.85);

    final word = l10n.introDemoSearch;
    final typed = word.substring(0, (word.length * typing).round());

    final entries = [
      (
        ScenePhotoKind.snow,
        l10n.introDemoTitle2,
        DateTime(today.year - 1, 1, 14),
      ),
      (ScenePhotoKind.lake, l10n.introDemoTitle, today),
      (
        ScenePhotoKind.party,
        l10n.introDemoTitle3,
        DateTime(today.year - 2, 3, 2),
      ),
    ];

    return Column(
      children: [
        // The search field.
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: ShapeDecoration(
            shape: StadiumBorder(
              side: BorderSide(color: scheme.outlineVariant),
            ),
            color: scheme.surfaceContainerHigh,
          ),
          child: Row(
            children: [
              Icon(Icons.search, size: 20, color: scheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  typed.isEmpty ? l10n.journalSearchHint : typed,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: typed.isEmpty
                        ? scheme.onSurfaceVariant
                        : scheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (typing > 0 && typing < 1)
                Container(width: 1.5, height: 18, color: scheme.primary),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < entries.length; i++) ...[
          Builder(
            builder: (context) {
              final (kind, title, date) = entries[i];
              final hit = title.toLowerCase().contains(word.toLowerCase());
              final appear = _phase(pages, i * 0.2, 0.6 + i * 0.2);
              final dim = hit ? 1.0 : 1 - 0.7 * filter;
              return Opacity(
                opacity: appear * dim,
                child: Transform.translate(
                  offset: Offset(0, 12 * (1 - appear)),
                  child: _NotebookPage(
                    kind: kind,
                    title: title,
                    date: Fmt.mediumDate(date),
                    highlight: hit && filter > 0 ? word : null,
                    tilt: const [-1.2, 0.8, -0.6][i],
                    lift: hit ? filter : 0,
                  ),
                ),
              );
            },
          ),
          if (i < entries.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _NotebookPage extends StatelessWidget {
  const _NotebookPage({
    required this.kind,
    required this.title,
    required this.date,
    required this.highlight,
    required this.tilt,
    required this.lift,
  });

  final ScenePhotoKind kind;
  final String title;
  final String date;
  final String? highlight;
  final double tilt;

  /// 0…1: the hit lifts a little off the page.
  final double lift;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final diary = context.diary;
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontFamily: AppFonts.serif,
      fontSize: 17,
      color: scheme.onSurface,
    );
    final mark = highlight;
    final start = mark == null
        ? -1
        : title.toLowerCase().indexOf(mark.toLowerCase());
    return Transform.scale(
      scale: 1 + 0.03 * lift,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: diary.paper,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: scheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: diary.polaroidShadow.withValues(alpha: 0.25 + 0.3 * lift),
              blurRadius: 3 + 6 * lift,
              offset: Offset(0, 1 + 2 * lift),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            SizedBox(
              width: 36,
              child: Polaroid(image: ScenePhoto(kind), tilt: tilt, tape: false),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    start < 0
                        ? TextSpan(text: title)
                        : TextSpan(
                            children: [
                              TextSpan(text: title.substring(0, start)),
                              TextSpan(
                                text: title.substring(
                                  start,
                                  start + mark!.length,
                                ),
                                style: TextStyle(
                                  backgroundColor: diary.highlight,
                                ),
                              ),
                              TextSpan(
                                text: title.substring(start + mark.length),
                              ),
                            ],
                          ),
                    style: titleStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    date,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

// --- 4: memories ------------------------------------------------------------

/// The entry comes back a year later: the polaroid rises with "1 year ago",
/// then the widget on the home screen shows it too.
class _MemoriesScene extends AnimatedWidget {
  const _MemoriesScene({required Animation<double> t, required this.l10n})
    : super(listenable: t);

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final t = (listenable as Animation<double>).value;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final rise = _phase(t, 0, 0.45);
    final label = _phase(t, 0.35, 0.6);
    final widgetIn = _phase(t, 0.6, 0.9, Curves.easeOutBack);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 40,
          top: 26,
          width: 150,
          child: Opacity(
            opacity: rise,
            child: Transform.translate(
              offset: Offset(0, 60 * (1 - rise)),
              child: Polaroid(
                image: const ScenePhoto(ScenePhotoKind.lake),
                title: l10n.introDemoTitle,
                tilt: 2,
              ),
            ),
          ),
        ),
        // "1 year ago" on a slip of paper.
        Positioned(
          left: 24,
          top: 6,
          child: Opacity(
            opacity: label,
            child: Transform.rotate(
              angle: -0.06,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.shadow.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  l10n.yearsAgo(1),
                  style: AppTheme.noteText(
                    context,
                    size: 16,
                  ).copyWith(color: scheme.onPrimaryContainer, height: 1.2),
                ),
              ),
            ),
          ),
        ),
        // The home screen widget.
        Positioned(
          right: 6,
          bottom: 4,
          width: 118,
          child: Opacity(
            opacity: widgetIn.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - widgetIn)),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.shadow.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const SizedBox(
                        height: 64,
                        width: double.infinity,
                        child: ScenePhoto(ScenePhotoKind.lake),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.yearsAgo(1),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      l10n.widgetTitle,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- the "photos" ------------------------------------------------------------

enum ScenePhotoKind { lake, snow, party }

/// A painted stand-in for a photo (the introduction shows no real ones):
/// a lake at sunset, a snowy hill, a birthday cake under fairy lights.
class ScenePhoto extends StatelessWidget {
  const ScenePhoto(this.kind, {super.key});

  final ScenePhotoKind kind;

  @override
  Widget build(BuildContext context) =>
      SizedBox.expand(child: CustomPaint(painter: _ScenePainter(kind)));
}

class _ScenePainter extends CustomPainter {
  const _ScenePainter(this.kind);

  final ScenePhotoKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final full = Offset.zero & size;
    Paint gradient(List<Color> colors, Rect rect) => Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
      ).createShader(rect);

    switch (kind) {
      case ScenePhotoKind.lake:
        canvas.drawRect(
          full,
          gradient(const [
            Color(0xFF6E5A9E),
            Color(0xFFE48A6A),
            Color(0xFFF6C27A),
          ], Rect.fromLTWH(0, 0, w, h * 0.62)),
        );
        canvas.drawCircle(
          Offset(w * 0.62, h * 0.58),
          w * 0.12,
          Paint()..color = const Color(0xFFFFE3A3),
        );
        final hills = Path()
          ..moveTo(0, h * 0.6)
          ..quadraticBezierTo(w * 0.2, h * 0.46, w * 0.42, h * 0.58)
          ..quadraticBezierTo(w * 0.7, h * 0.5, w, h * 0.6)
          ..lineTo(w, h * 0.62)
          ..lineTo(0, h * 0.62)
          ..close();
        canvas.drawPath(hills, Paint()..color = const Color(0xFF4A3B5E));
        final water = Rect.fromLTWH(0, h * 0.62, w, h * 0.38);
        canvas.drawRect(
          water,
          gradient(const [Color(0xFF8C6E9E), Color(0xFF3E4F7A)], water),
        );
        final glint = Paint()
          ..color = const Color(0xFFFFE3A3).withValues(alpha: 0.75)
          ..strokeWidth = h * 0.018
          ..strokeCap = StrokeCap.round;
        for (var i = 0; i < 4; i++) {
          final y = h * (0.67 + i * 0.07);
          final half = w * (0.1 - i * 0.018);
          canvas.drawLine(
            Offset(w * 0.62 - half, y),
            Offset(w * 0.62 + half, y),
            glint,
          );
        }
      case ScenePhotoKind.snow:
        canvas.drawRect(
          full,
          gradient(const [Color(0xFF9DB4CC), Color(0xFFDCE6EF)], full),
        );
        final back = Path()
          ..moveTo(0, h * 0.62)
          ..quadraticBezierTo(w * 0.35, h * 0.4, w * 0.7, h * 0.58)
          ..quadraticBezierTo(w * 0.85, h * 0.64, w, h * 0.56)
          ..lineTo(w, h)
          ..lineTo(0, h)
          ..close();
        canvas.drawPath(back, Paint()..color = const Color(0xFFEAF0F5));
        final tree = Paint()..color = const Color(0xFF2F5D50);
        for (final (x, s) in [(0.22, 1.0), (0.32, 0.75), (0.78, 0.9)]) {
          final base = Offset(w * x, h * (x < 0.5 ? 0.6 : 0.64));
          canvas.drawPath(
            Path()
              ..moveTo(base.dx, base.dy - h * 0.26 * s)
              ..lineTo(base.dx + w * 0.07 * s, base.dy)
              ..lineTo(base.dx - w * 0.07 * s, base.dy)
              ..close(),
            tree,
          );
        }
        final front = Path()
          ..moveTo(0, h * 0.8)
          ..quadraticBezierTo(w * 0.5, h * 0.66, w, h * 0.82)
          ..lineTo(w, h)
          ..lineTo(0, h)
          ..close();
        canvas.drawPath(front, Paint()..color = Colors.white);
        final flake = Paint()..color = Colors.white.withValues(alpha: 0.9);
        final random = Random(7);
        for (var i = 0; i < 18; i++) {
          canvas.drawCircle(
            Offset(random.nextDouble() * w, random.nextDouble() * h * 0.7),
            w * (0.008 + random.nextDouble() * 0.012),
            flake,
          );
        }
      case ScenePhotoKind.party:
        canvas.drawRect(
          full,
          gradient(const [Color(0xFF3B2433), Color(0xFF6B3A3F)], full),
        );
        final random = Random(3);
        const lights = [
          Color(0xFFFFD27A),
          Color(0xFFFF9E7A),
          Color(0xFFF7B2C4),
        ];
        for (var i = 0; i < 14; i++) {
          canvas.drawCircle(
            Offset(random.nextDouble() * w, random.nextDouble() * h * 0.55),
            w * (0.03 + random.nextDouble() * 0.05),
            Paint()
              ..color = lights[i % 3].withValues(
                alpha: 0.25 + random.nextDouble() * 0.35,
              ),
          );
        }
        final plate = Rect.fromLTWH(w * 0.18, h * 0.82, w * 0.64, h * 0.05);
        canvas.drawRRect(
          RRect.fromRectAndRadius(plate, Radius.circular(h * 0.03)),
          Paint()..color = const Color(0xFFE9DDD0),
        );
        final cake = Rect.fromLTWH(w * 0.26, h * 0.58, w * 0.48, h * 0.25);
        canvas.drawRRect(
          RRect.fromRectAndRadius(cake, Radius.circular(w * 0.04)),
          Paint()..color = const Color(0xFFF4E1C6),
        );
        canvas.drawRect(
          Rect.fromLTWH(
            cake.left,
            cake.top + cake.height * 0.45,
            cake.width,
            cake.height * 0.14,
          ),
          Paint()..color = const Color(0xFFE38FA2),
        );
        for (var i = 0; i < 3; i++) {
          final x = cake.left + cake.width * (0.25 + i * 0.25);
          canvas.drawRect(
            Rect.fromLTWH(
              x - w * 0.012,
              cake.top - h * 0.12,
              w * 0.024,
              h * 0.12,
            ),
            Paint()..color = const Color(0xFFF7F1E8),
          );
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(x, cake.top - h * 0.16),
              width: w * 0.04,
              height: h * 0.07,
            ),
            Paint()..color = const Color(0xFFFFC857),
          );
        }
    }
  }

  @override
  bool shouldRepaint(_ScenePainter old) => old.kind != kind;
}
