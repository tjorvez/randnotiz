import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/app/covered_page.dart';

void main() {
  testWidgets('a covered page does not see (or rebuild for) the keyboard', (
    t,
  ) async {
    final below = <double>[];
    final key = GlobalKey<NavigatorState>();
    // One instance for every pump: only a dependency can rebuild it.
    final page = CoveredPageInsets(
      child: Builder(
        builder: (context) {
          below.add(MediaQuery.viewInsetsOf(context).bottom);
          return const SizedBox();
        },
      ),
    );
    Widget app(double keyboard) => MediaQuery(
      data: MediaQueryData(
        size: const Size(400, 800),
        viewInsets: EdgeInsets.only(bottom: keyboard),
      ),
      child: MaterialApp(navigatorKey: key, home: page),
    );

    await t.pumpWidget(app(0));
    await t.pumpWidget(app(100));
    expect(below.last, 100, reason: 'on top: the real keyboard');

    key.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => const Scaffold()),
    );
    await t.pumpAndSettle();
    final builds = below.length;
    // The keyboard slides in and out on the page above.
    for (final k in <double>[0, 120, 240, 300]) {
      await t.pumpWidget(app(k));
    }
    expect(below.length, builds, reason: 'no rebuilds while covered');

    key.currentState!.pop();
    await t.pumpAndSettle();
    expect(below.last, 300, reason: 'on top again: real insets');
  });
}
