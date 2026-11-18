import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/features/music/presentation/record_roll.dart';

const _record = SizedBox.square(key: ValueKey('record'), dimension: 100);

void main() {
  /// Opacity of the record (1 when no Opacity wraps it).
  double opacity(WidgetTester t) {
    final o = find.ancestor(
      of: find.byKey(const ValueKey('record')),
      matching: find.byType(Opacity),
    );
    return o.evaluate().isEmpty ? 1 : t.widget<Opacity>(o.first).opacity;
  }

  double left(WidgetTester t) =>
      t.getTopLeft(find.byKey(const ValueKey('record'))).dx;

  /// Opens a page with the record (300 ms transition that moves nothing,
  /// so only the record's own movement shows).
  Future<void> open(WidgetTester t, {bool reduceMotion = false}) async {
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              PageRouteBuilder<void>(
                transitionDuration: const Duration(milliseconds: 300),
                reverseTransitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (context, _, _) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(disableAnimations: reduceMotion),
                  child: const Align(
                    alignment: Alignment.topLeft,
                    child: RecordRoll(size: 100, child: _record),
                  ),
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await t.pump();
  }

  testWidgets('hidden while the page opens, then rolls in from the right', (
    t,
  ) async {
    await open(t);
    // Halfway through the page transition: not there yet.
    await t.pump(const Duration(milliseconds: 150));
    expect(opacity(t), 0);

    // The page has opened: it starts rolling in from the right.
    await t.pump(const Duration(milliseconds: 300));
    await t.pump(const Duration(milliseconds: 100));
    expect(opacity(t), greaterThan(0));
    expect(left(t), greaterThan(0));

    await t.pumpAndSettle();
    expect(opacity(t), 1);
    expect(left(t), 0);

    // Closing: it rolls out to the right.
    final navigator = t.state<NavigatorState>(find.byType(Navigator));
    navigator.pop();
    await t.pump();
    await t.pump(const Duration(milliseconds: 120));
    expect(left(t), greaterThan(0));
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('record')), findsNothing);
  });

  testWidgets('reduce motion: simply there', (t) async {
    await open(t, reduceMotion: true);
    await t.pump(const Duration(milliseconds: 50));
    expect(opacity(t), 1);
    expect(left(t), 0);
    await t.pumpAndSettle();
  });
}
