import 'dart:math';
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Proportions shared by every polaroid of the app, relative to the width of
/// the card. Because the frame scales with the card, a small polaroid in a
/// list is an exact miniature of the large one on the note page – the
/// photo can fly between them without changing shape.
abstract final class PolaroidGeometry {
  /// Left, right and top frame.
  static const double side = 0.045;

  /// The broad bottom rim (where the title is written).
  static const double rim = 0.15;

  /// Width / height of a card around a photo with [photoAspect].
  static double cardAspect(double photoAspect) =>
      1 / (side + (1 - 2 * side) / photoAspect + rim);

  /// Height of the bottom rim of a card [width] wide.
  static double rimHeight(double width) => width * rim;

  /// Below this rim height a title would be unreadable and is left out.
  static const double minRimForTitle = 21;

  /// Width of the washi tape strips relative to the card.
  static const double tape = 0.17;

  /// Sanitises an aspect ratio from the database or gallery.
  static double photoAspectOrSquare(double? aspect) =>
      aspect == null || !aspect.isFinite || aspect <= 0
      ? 1
      : aspect.clamp(0.3, 3.5);
}

/// Ink colour of the handwritten title (the rim is light in both themes).
const Color polaroidInk = Color(0xFF3A2A1F);

/// A photo framed like a polaroid with a soft shadow and optional washi tape.
///
/// The card has the exact proportions of [PolaroidGeometry]: its height
/// never depends on whether a [title] is shown. Use it inside a widget that
/// gives it a width (e.g. a `SizedBox`).
class Polaroid extends StatelessWidget {
  const Polaroid({
    super.key,
    required this.image,
    this.title,
    this.rim,
    this.tilt = 0,
    this.tape = true,
    this.photoAspect = 1,
    this.hero,
  });

  final Widget image;

  /// Handwritten on the rim (single line, shrinks, then ellipsis).
  final String? title;

  /// Custom rim content instead of [title] (e.g. a text field).
  final Widget? rim;

  /// Rotation in degrees (a small tilt looks hand-placed).
  final double tilt;
  final bool tape;

  /// Width / height of the photo.
  final double photoAspect;

  /// Makes the whole polaroid (frame, photo and title) a shared element.
  final PolaroidHero? hero;

  /// A stable tilt between -2.5° and 2.5° derived from [seed]. Use the
  /// note's asset id, so every polaroid of a note has the same tilt.
  static double tiltFor(Object seed) =>
      (Random(seed.hashCode).nextDouble() - 0.5) * 5;

  @override
  Widget build(BuildContext context) {
    final aspect = PolaroidGeometry.photoAspectOrSquare(photoAspect);
    final content = PolaroidFrame(
      image: image,
      rim:
          rim ??
          (title == null || title!.trim().isEmpty
              ? null
              : PolaroidTitle(title!)),
      tilt: tilt,
      tape: tape ? 1 : 0,
    );
    final heroData = hero;
    return AspectRatio(
      aspectRatio: PolaroidGeometry.cardAspect(aspect),
      child: heroData == null
          ? content
          : _PolaroidHeroScope(
              data: _PolaroidHeroData(
                image: heroData.flightImage ?? image,
                title: title,
                tilt: tilt,
                tape: tape ? 1 : 0,
              ),
              child: Hero(
                tag: heroData.tag,
                createRectTween: _linearRect,
                flightShuttleBuilder: _polaroidShuttle,
                child: content,
              ),
            ),
    );
  }
}

/// Shared-element settings of a [Polaroid].
@immutable
class PolaroidHero {
  const PolaroidHero({required this.tag, this.flightImage});

  /// Must be unique on a page and identical on both ends of the flight.
  final Object tag;

  /// Image shown while flying if this side is the list side; defaults to
  /// the polaroid's image. Should be an image that is already decoded.
  final Widget? flightImage;
}

/// The unrotated card plus tilt and tape. [tape] (0…1) is the tape's
/// opacity.
class PolaroidFrame extends StatelessWidget {
  const PolaroidFrame({
    super.key,
    required this.image,
    this.rim,
    this.tilt = 0,
    this.tape = 1,
    this.rimOpacity = 1,
  });

  final Widget image;
  final Widget? rim;
  final double tilt;
  final double tape;
  final double rimOpacity;

  @override
  Widget build(BuildContext context) {
    final diary = context.diary;
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final side = w * PolaroidGeometry.side;
        final rimHeight = PolaroidGeometry.rimHeight(w);
        final card = DecoratedBox(
          decoration: BoxDecoration(
            color: diary.polaroidFrame,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: diary.polaroidShadow,
                blurRadius: 14,
                spreadRadius: -2,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: diary.polaroidShadow.withValues(alpha: 0.12),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(side, side, side, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: ClipRect(child: image)),
                SizedBox(
                  height: rimHeight,
                  child: rim == null || rimOpacity <= 0
                      ? null
                      : Opacity(opacity: rimOpacity.clamp(0, 1), child: rim),
                ),
              ],
            ),
          ),
        );
        final tapeWidth = w * PolaroidGeometry.tape;
        final framed = tape <= 0
            ? card
            : Stack(
                clipBehavior: Clip.none,
                fit: StackFit.expand,
                children: [
                  card,
                  Positioned(
                    top: -tapeWidth * 0.17,
                    left: -tapeWidth * 0.22,
                    child: Opacity(
                      opacity: tape.clamp(0, 1),
                      child: WashiTape(
                        angle: -0.6,
                        color: diary.washiTape,
                        width: tapeWidth,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -tapeWidth * 0.17,
                    right: -tapeWidth * 0.22,
                    child: Opacity(
                      opacity: tape.clamp(0, 1),
                      child: WashiTape(
                        angle: 0.55,
                        color: diary.washiTape,
                        width: tapeWidth,
                      ),
                    ),
                  ),
                ],
              );
        return Transform.rotate(angle: tilt * pi / 180, child: framed);
      },
    );
  }
}

/// The title, handwritten on the rim: one line, as large as fits; long
/// titles get a smaller script down to a minimum, then an ellipsis. Shows
/// nothing if the rim is too small to read it.
class PolaroidTitle extends StatelessWidget {
  const PolaroidTitle(this.title, {super.key, this.color = polaroidInk});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final rimHeight = constraints.maxHeight;
      if (rimHeight < PolaroidGeometry.minRimForTitle) {
        return const SizedBox.shrink();
      }
      final fit = PolaroidTitleFit.compute(
        title,
        width: constraints.maxWidth * 0.92,
        rimHeight: rimHeight,
      );
      // Fades in just above the minimum size, so a growing polaroid (hero
      // flight) does not make the title pop up.
      final fade = ((rimHeight - PolaroidGeometry.minRimForTitle) / 6).clamp(
        0.0,
        1.0,
      );
      final text = Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth * 0.04,
          ),
          child: Text(
            title,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            textScaler: TextScaler.noScaling,
            style: PolaroidTitleFit.style(fit.fontSize, color),
          ),
        ),
      );
      return fade >= 1 ? text : Opacity(opacity: fade, child: text);
    },
  );
}

/// Font size of a title on a rim of a given size.
@immutable
class PolaroidTitleFit {
  const PolaroidTitleFit(this.fontSize, {required this.overflows});

  final double fontSize;

  /// Even at the minimum size the title is too long (→ ellipsis).
  final bool overflows;

  static double maxFontFor(double rimHeight) =>
      (rimHeight * 0.5).clamp(9.0, 28.0);

  static double minFontFor(double rimHeight) =>
      max(9, maxFontFor(rimHeight) * 0.62);

  static TextStyle style(double fontSize, Color color) => TextStyle(
    fontFamily: AppFonts.handwriting,
    fontSize: fontSize,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    decoration: TextDecoration.none,
    height: 1.25,
    color: color,
  );

  static double widthAt(String text, double fontSize) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style(fontSize, polaroidInk)),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final w = painter.width;
    painter.dispose();
    return w;
  }

  static PolaroidTitleFit compute(
    String text, {
    required double width,
    required double rimHeight,
  }) {
    final maxFont = maxFontFor(rimHeight);
    final minFont = minFontFor(rimHeight);
    final atMax = widthAt(text, maxFont);
    if (atMax <= width) return PolaroidTitleFit(maxFont, overflows: false);
    // Text width grows linearly with the font size.
    var size = (maxFont * width / atMax).floorToDouble();
    while (size > minFont && widthAt(text, size) > width) {
      size -= 0.5;
    }
    if (size <= minFont) {
      return PolaroidTitleFit(
        minFont,
        overflows: widthAt(text, minFont) > width,
      );
    }
    return PolaroidTitleFit(size, overflows: false);
  }
}

// --- shared element -----------------------------------------------------------

/// What one end of a polaroid flight looks like.
@immutable
class _PolaroidHeroData {
  const _PolaroidHeroData({
    required this.image,
    required this.tilt,
    required this.tape,
    this.title,
  });

  final Widget image;
  final String? title;
  final double tilt;
  final double tape;
}

class _PolaroidHeroScope extends StatelessWidget {
  const _PolaroidHeroScope({required this.data, required this.child});

  final _PolaroidHeroData data;
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// Straight-line flight: with equal proportions on both ends the card keeps
/// its proportions all the way (Material's arc would bend them).
RectTween _linearRect(Rect? begin, Rect? end) =>
    RectTween(begin: begin, end: end);

Widget _polaroidShuttle(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection direction,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final from = fromHeroContext
      .findAncestorWidgetOfExactType<_PolaroidHeroScope>()
      ?.data;
  final to = toHeroContext
      .findAncestorWidgetOfExactType<_PolaroidHeroScope>()
      ?.data;
  if (from == null || to == null) {
    return (toHeroContext.widget as Hero).child;
  }
  // `animation` is the note page's route animation (1 = page fully shown),
  // for pushes and pops alike.
  final push = direction == HeroFlightDirection.push;
  final page = push ? to : from;
  final list = push ? from : to;
  // Pushing: the list's image is decoded already. Popping: the page's
  // larger image is decoded and looks sharper while the card is big.
  final image = push ? list.image : page.image;
  final title = page.title ?? list.title;
  // The flight happens in the overlay, outside any Material: without one,
  // text would get Flutter's fallback style (bold, yellow underline).
  return Material(
    type: MaterialType.transparency,
    child: _PolaroidFlight(
      animation: animation,
      list: list,
      page: page,
      image: image,
      title: title,
    ),
  );
}

class _PolaroidFlight extends AnimatedWidget {
  const _PolaroidFlight({
    required Animation<double> animation,
    required this.list,
    required this.page,
    required this.image,
    required this.title,
  }) : super(listenable: animation);

  final _PolaroidHeroData list;
  final _PolaroidHeroData page;
  final Widget image;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final t = (listenable as Animation<double>).value;
    final hasTitle = title != null && title!.trim().isNotEmpty;
    return PolaroidFrame(
      image: image,
      rim: hasTitle ? PolaroidTitle(title!) : null,
      // The rim shows the title on both ends if both have one; otherwise
      // it fades in (or out) on the way.
      rimOpacity: lerpDouble(
        list.title == null ? 0 : 1,
        page.title == null ? 0 : 1,
        t,
      )!,
      tilt: lerpDouble(list.tilt, page.tilt, t)!,
      tape: lerpDouble(list.tape, page.tape, t)!,
    );
  }
}

/// A small strip of semi-transparent paper tape with torn ends.
class WashiTape extends StatelessWidget {
  const WashiTape({
    super.key,
    required this.angle,
    required this.color,
    this.width = 46,
  });

  final double angle;
  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: angle,
    child: CustomPaint(
      size: Size(width, width * 0.33),
      painter: _TapePainter(color),
    ),
  );
}

class _TapePainter extends CustomPainter {
  _TapePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const teeth = 4;
    final h = size.height;
    final tooth = size.width * 0.054;
    final path = Path()..moveTo(0, 0);
    path.lineTo(size.width, 0);
    for (var i = 0; i <= teeth; i++) {
      path.lineTo(size.width - (i.isOdd ? tooth : 0), h * i / teeth);
    }
    path.lineTo(0, h);
    for (var i = teeth; i >= 0; i--) {
      path.lineTo(i.isOdd ? tooth : 0, h * i / teeth);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
    // faint stripes
    final stripe = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = size.width * 0.043;
    final step = size.width * 0.17;
    for (var x = step * 0.75; x < size.width - step * 0.5; x += step) {
      canvas.drawLine(
        Offset(x, 1),
        Offset(x - size.width * 0.065, h - 1),
        stripe,
      );
    }
  }

  @override
  bool shouldRepaint(_TapePainter old) => old.color != color;
}
