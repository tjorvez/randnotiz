import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/core/theme/app_theme.dart';
import 'package:randnotiz/core/theme/season.dart';
import 'package:randnotiz/core/widgets/polaroid.dart';
import 'package:randnotiz/features/notes/presentation/rim_title_field.dart';
import 'package:randnotiz/l10n/generated/app_localizations.dart';

void main() {
  late TextEditingController controller;
  late FocusNode focus;

  setUp(() {
    controller = TextEditingController();
    focus = FocusNode();
  });
  tearDown(() {
    controller.dispose();
    focus.dispose();
  });

  Future<void> pump(WidgetTester tester, Brightness brightness) =>
      tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.build(brightness, Season.autumn),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 320,
                child: Polaroid(
                  key: const ValueKey('p'),
                  photoAspect: 0.75,
                  title: controller.text,
                  rim: RimTitleField(controller: controller, focusNode: focus),
                  image: const ColoredBox(color: Colors.teal),
                ),
              ),
            ),
          ),
        ),
      );

  for (final brightness in Brightness.values) {
    testWidgets('empty: shows the hint and edits on tap ($brightness)', (
      tester,
    ) async {
      await pump(tester, brightness);
      expect(find.text('Titel'), findsOneWidget);
      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(focus.hasFocus, isTrue);
      await tester.enterText(find.byType(TextField), 'Am See');
      expect(controller.text, 'Am See');
    });
  }

  testWidgets('an existing title can be tapped to edit it', (tester) async {
    controller.text = 'Flohmarkt in Eppendorf am Sonntagnachmittag mit Tobi';
    await pump(tester, Brightness.light);
    final height = tester.getSize(find.byKey(const ValueKey('p'))).height;

    // Not editing: the display text (ellipsis) covers the hidden field.
    final display = find.byType(PolaroidTitle);
    expect(display, findsOneWidget);
    expect(
      tester
          .widget<Text>(
            find.descendant(of: display, matching: find.byType(Text)),
          )
          .overflow,
      TextOverflow.ellipsis,
    );

    await tester.tap(display);
    await tester.pump();
    expect(focus.hasFocus, isTrue, reason: 'the tap must reach the field');
    expect(find.byType(PolaroidTitle), findsNothing);
    expect(controller.selection.baseOffset, controller.text.length);

    // Line breaks are not possible; the length is limited.
    await tester.enterText(find.byType(TextField), 'a\nb${'x' * 100}');
    expect(controller.text.contains('\n'), isFalse);
    expect(controller.text.length, RimTitleField.maxLength);

    // Editing never changes the polaroid's height.
    expect(tester.getSize(find.byKey(const ValueKey('p'))).height, height);

    focus.unfocus();
    await tester.pump();
    expect(find.byType(PolaroidTitle), findsOneWidget);
  });
}
