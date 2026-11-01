import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/app/router.dart' show NotePage;
import 'package:randnotiz/core/theme/app_theme.dart';
import 'package:randnotiz/core/theme/season.dart';
import 'package:randnotiz/core/widgets/polaroid.dart';

/// Measures the shared-element flight of a polaroid frame by frame: the
/// photo must never slide inside its frame, keep its proportions and tilt,
/// and start and end exactly where the photo is on screen.
void main() {
  const listImage = ValueKey('img-list');
  const pageImage = ValueKey('img-page');
  const tag = 'polaroid:journal:asset-42';
  const aspect = 0.75;
  final tilt = Polaroid.tiltFor('asset-42');
  const listWidth = 92.0;
  const pageWidth = 300.0;

  /// The four corners of [finder]'s box on screen (rotation included).
  List<Offset> corners(WidgetTester t, Finder finder, {RenderBox? within}) {
    final box = t.renderObject<RenderBox>(finder);
    final s = box.size;
    return [
      for (final p in [
        Offset.zero,
        Offset(s.width, 0),
        Offset(0, s.height),
        Offset(s.width, s.height),
      ])
        box.localToGlobal(p, ancestor: within),
    ];
  }

  double maxDistance(List<Offset> a, List<Offset> b) =>
      [for (var i = 0; i < 4; i++) (a[i] - b[i]).distance].reduce(max);

  double angleOf(List<Offset> c) => atan2(c[1].dy - c[0].dy, c[1].dx - c[0].dx);

  /// The unrotated card that holds [image] (the child of the polaroid's
  /// rotation), to measure the photo's position inside its frame.
  RenderBox cardOf(WidgetTester t, Finder image) {
    final frame = find
        .ancestor(of: image, matching: find.byType(PolaroidFrame))
        .first;
    return t.renderObject<RenderBox>(
      find.descendant(of: frame, matching: find.byType(DecoratedBox)).first,
    );
  }

  /// Checks the photo sits exactly where the geometry puts it in its card.
  void expectPhotoInFrame(WidgetTester t, Finder image, String when) {
    final card = cardOf(t, image);
    final w = card.size.width;
    final local = corners(t, image, within: card);
    final side = w * PolaroidGeometry.side;
    expect(local[0].dx, closeTo(side, 0.6), reason: '$when: left');
    expect(local[0].dy, closeTo(side, 0.6), reason: '$when: top');
    expect(local[1].dx, closeTo(w - side, 0.6), reason: '$when: right');
    expect(
      card.size.height - local[3].dy,
      closeTo(PolaroidGeometry.rimHeight(w), 0.6),
      reason: '$when: rim',
    );
  }

  /// The flying title is drawn in the app's handwriting – never in
  /// Flutter's fallback style for text outside a Material.
  void expectPlainTitle(WidgetTester t, String title) {
    for (final p in t.renderObjectList<RenderParagraph>(
      find.text(title, skipOffstage: false),
    )) {
      final style = p.text.style!;
      expect(style.decoration, TextDecoration.none);
      expect(style.fontWeight, FontWeight.w400);
      expect(style.fontFamily, AppFonts.handwriting);
    }
  }

  Widget polaroid({
    required double width,
    required Key imageKey,
    required bool tape,
    String? title,
  }) => SizedBox(
    width: width,
    child: Polaroid(
      tilt: tilt,
      tape: tape,
      photoAspect: aspect,
      title: title,
      hero: const PolaroidHero(tag: tag),
      image: ColoredBox(key: imageKey, color: Colors.teal),
    ),
  );

  for (final brightness in Brightness.values) {
    for (final title in [null, 'Sonntag am Meer']) {
      final name = '${brightness.name}, ${title == null ? 'no' : 'with'} title';

      testWidgets('push and pop keep the photo in its frame ($name)', (
        t,
      ) async {
        final nav = GlobalKey<NavigatorState>();
        await t.pumpWidget(
          MaterialApp(
            navigatorKey: nav,
            theme: AppTheme.build(Brightness.light, Season.autumn),
            darkTheme: AppTheme.build(Brightness.dark, Season.autumn),
            themeMode: brightness == Brightness.dark
                ? ThemeMode.dark
                : ThemeMode.light,
            home: Scaffold(
              body: Align(
                alignment: const Alignment(-0.8, 0.3),
                child: polaroid(
                  width: listWidth,
                  imageKey: listImage,
                  tape: false,
                  title: title,
                ),
              ),
            ),
          ),
        );
        final start = corners(t, find.byKey(listImage));

        unawaited(
          nav.currentState!.push(
            NotePage<void>(
              child: Scaffold(
                body: Padding(
                  padding: const EdgeInsets.only(top: 90),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: polaroid(
                      width: pageWidth,
                      imageKey: pageImage,
                      tape: true,
                      title: title,
                    ),
                  ),
                ),
              ),
            ).createRoute(nav.currentContext!),
          ),
        );

        // --- push: the list's photo flies (it is decoded already) ---
        final flight = <List<Offset>>[];
        await t.pump(); // builds the page
        await t.pump(); // flight starts
        while (find.byKey(listImage).evaluate().isNotEmpty &&
            find.byKey(pageImage).hitTestable().evaluate().isEmpty) {
          final image = find.byKey(listImage);
          expectPhotoInFrame(t, image, 'push frame ${flight.length}');
          if (title != null) expectPlainTitle(t, title);
          flight.add(corners(t, image));
          await t.pump(const Duration(milliseconds: 16));
        }
        await t.pumpAndSettle();
        final end = corners(t, find.byKey(pageImage));
        expect(flight.length, greaterThan(10), reason: 'frames measured');

        // Starts and lands exactly on the photos on screen: no jump.
        expect(maxDistance(start, flight.first), lessThan(1.5));
        expect(maxDistance(flight.last, end), lessThan(1.5));
        // Same tilt on both ends: the photo does not turn on the way.
        for (final c in flight) {
          expect(angleOf(c), closeTo(angleOf(start), 1e-3));
        }
        // It grows continuously: no frame jumps back or skips ahead.
        double widthOf(List<Offset> c) => (c[1] - c[0]).distance;
        for (var i = 1; i < flight.length; i++) {
          expect(
            widthOf(flight[i]),
            greaterThanOrEqualTo(widthOf(flight[i - 1]) - 0.01),
          );
          expect(
            widthOf(flight[i]) / (flight[i][2] - flight[i][0]).distance,
            closeTo(aspect, 0.01),
            reason: 'photo keeps its proportions',
          );
        }

        // --- pop: the page's photo flies back ---
        nav.currentState!.pop();
        await t.pump();
        await t.pump();
        final back = <List<Offset>>[];
        while (find.byKey(pageImage).evaluate().isNotEmpty) {
          final image = find.byKey(pageImage);
          expectPhotoInFrame(t, image, 'pop frame ${back.length}');
          back.add(corners(t, image));
          await t.pump(const Duration(milliseconds: 16));
        }
        await t.pumpAndSettle();
        expect(back.length, greaterThan(8));
        expect(maxDistance(back.first, end), lessThan(1.5));
        expect(
          maxDistance(back.last, corners(t, find.byKey(listImage))),
          lessThan(1.5),
        );
        expect(t.takeException(), isNull);
      });
    }
  }

  testWidgets('a frameless tile grows its frame on the way', (t) async {
    final nav = GlobalKey<NavigatorState>();
    await t.pumpWidget(
      MaterialApp(
        navigatorKey: nav,
        theme: AppTheme.build(Brightness.light, Season.autumn),
        home: const Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox.square(
              dimension: 120,
              child: FramelessPolaroidHero(
                tag: tag,
                image: ColoredBox(key: listImage, color: Colors.teal),
              ),
            ),
          ),
        ),
      ),
    );
    final start = corners(t, find.byKey(listImage));
    unawaited(
      nav.currentState!.push(
        NotePage<void>(
          child: Scaffold(
            body: Center(
              child: polaroid(
                width: pageWidth,
                imageKey: pageImage,
                tape: true,
              ),
            ),
          ),
        ).createRoute(nav.currentContext!),
      ),
    );
    await t.pump();
    await t.pump();
    expect(
      maxDistance(start, corners(t, find.byKey(listImage))),
      lessThan(1.5),
    );
    final frames = <double>[];
    while (find.byKey(listImage).evaluate().isNotEmpty &&
        find.byKey(pageImage).hitTestable().evaluate().isEmpty) {
      final card = cardOf(t, find.byKey(listImage));
      final inset = corners(t, find.byKey(listImage), within: card)[0].dx;
      frames.add(inset / card.size.width);
      await t.pump(const Duration(milliseconds: 16));
    }
    await t.pumpAndSettle();
    // The frame grows from nothing to a polaroid's frame, never shrinking.
    expect(frames.first, lessThan(0.01));
    expect(frames.last, closeTo(PolaroidGeometry.side, 0.01));
    for (var i = 1; i < frames.length; i++) {
      expect(frames[i], greaterThanOrEqualTo(frames[i - 1] - 1e-6));
    }
  });

  testWidgets('"reduce motion": nothing flies, the page only fades', (t) async {
    final nav = GlobalKey<NavigatorState>();
    await t.pumpWidget(
      MaterialApp(
        navigatorKey: nav,
        theme: AppTheme.build(Brightness.light, Season.autumn),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: polaroid(width: listWidth, imageKey: listImage, tape: false),
          ),
        ),
      ),
    );
    final start = corners(t, find.byKey(listImage));
    unawaited(
      nav.currentState!.push(
        NotePage<void>(
          reduceMotion: true,
          child: Scaffold(
            body: Center(
              child: polaroid(
                width: pageWidth,
                imageKey: pageImage,
                tape: true,
              ),
            ),
          ),
        ).createRoute(nav.currentContext!),
      ),
    );
    await t.pump();
    await t.pump(const Duration(milliseconds: 60));
    // The list's polaroid stays where it is (no shuttle), the page's is
    // already in place.
    expect(maxDistance(start, corners(t, find.byKey(listImage))), 0);
    expect(find.byKey(pageImage), findsOneWidget);
    await t.pumpAndSettle();
  });
}
