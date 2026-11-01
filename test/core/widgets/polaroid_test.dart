import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/core/theme/app_theme.dart';
import 'package:randnotiz/core/theme/season.dart';
import 'package:randnotiz/core/widgets/polaroid.dart';

void main() {
  Widget host(Widget child, {Brightness brightness = Brightness.light}) =>
      MaterialApp(
        theme: AppTheme.build(brightness, Season.autumn),
        home: Scaffold(
          body: Center(child: SizedBox(width: 300, child: child)),
        ),
      );

  Widget polaroid({String? title, double aspect = 0.75}) => Polaroid(
    key: const ValueKey('p'),
    photoAspect: aspect,
    title: title,
    image: const ColoredBox(color: Colors.teal),
  );

  group('geometry', () {
    test('the frame scales with the card', () {
      // A list miniature has exactly the proportions of the large card.
      expect(
        PolaroidGeometry.cardAspect(0.75),
        closeTo(1 / (0.045 + 0.91 / 0.75 + 0.15), 1e-9),
      );
      expect(PolaroidGeometry.rimHeight(300), 45);
      expect(PolaroidGeometry.photoAspectOrSquare(null), 1);
      expect(PolaroidGeometry.photoAspectOrSquare(double.nan), 1);
      expect(PolaroidGeometry.photoAspectOrSquare(-2), 1);
      expect(PolaroidGeometry.photoAspectOrSquare(20), 3.5);
    });
  });

  group('title on the rim', () {
    for (final brightness in Brightness.values) {
      testWidgets('does not change the height ($brightness)', (tester) async {
        await tester.pumpWidget(host(polaroid(), brightness: brightness));
        final without = tester.getSize(find.byKey(const ValueKey('p')));
        await tester.pumpWidget(
          host(polaroid(title: 'Sonntag am Meer'), brightness: brightness),
        );
        final withTitle = tester.getSize(find.byKey(const ValueKey('p')));
        expect(withTitle, without);
        expect(find.text('Sonntag am Meer'), findsOneWidget);
        await tester.pumpWidget(
          host(
            polaroid(title: 'Ein sehr langer Titel ' * 6),
            brightness: brightness,
          ),
        );
        expect(tester.getSize(find.byKey(const ValueKey('p'))), without);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('long titles shrink, very long ones end with an ellipsis', (
      tester,
    ) async {
      double fontOf(String text) =>
          tester.widget<Text>(find.text(text)).style!.fontSize!;
      final rim = PolaroidGeometry.rimHeight(300);

      await tester.pumpWidget(host(polaroid(title: 'Meer')));
      final short = fontOf('Meer');
      expect(short, PolaroidTitleFit.maxFontFor(rim));

      const medium = 'Der Sonntag, an dem wir den Leuchtturm fanden';
      await tester.pumpWidget(host(polaroid(title: medium)));
      final mediumSize = fontOf(medium);
      expect(mediumSize, lessThan(short));
      expect(
        mediumSize,
        greaterThanOrEqualTo(PolaroidTitleFit.minFontFor(rim)),
      );

      final long = 'Ein sehr langer Titel ' * 6;
      await tester.pumpWidget(host(polaroid(title: long)));
      final text = tester.widget<Text>(find.text(long));
      expect(text.style!.fontSize, PolaroidTitleFit.minFontFor(rim));
      expect(text.overflow, TextOverflow.ellipsis);
      expect(text.maxLines, 1);
    });

    testWidgets('tiny polaroids leave the title out', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.build(Brightness.light, Season.autumn),
          home: Center(
            child: SizedBox(width: 92, child: polaroid(title: 'Meer')),
          ),
        ),
      );
      // 92 px card → 13.8 px rim: unreadable, so nothing is drawn.
      expect(find.text('Meer'), findsNothing);
    });
  });

  test('fit: font sizes stay within the rim', () {
    for (final rim in [21.0, 30.0, 45.0, 80.0]) {
      final max = PolaroidTitleFit.maxFontFor(rim);
      final min = PolaroidTitleFit.minFontFor(rim);
      expect(min, lessThan(max));
      expect(max * 1.25, lessThanOrEqualTo(rim * 0.7));
    }
  });
}
