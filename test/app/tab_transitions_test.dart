import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/app/tab_transitions.dart';

void main() {
  Widget tab(int i) => ListView.builder(
    key: PageStorageKey('tab$i'),
    itemCount: 100,
    itemBuilder: (_, n) => SizedBox(height: 50, child: Text('tab$i item$n')),
  );

  Widget host(int index, {bool reduceMotion = false}) => MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: SlidingTabStack(
        currentIndex: index,
        children: [for (var i = 0; i < 4; i++) tab(i)],
      ),
    ),
  );

  double xOf(WidgetTester t, String text) => t.getTopLeft(find.text(text)).dx;

  testWidgets('slides in the direction of the tab order', (t) async {
    await t.pumpWidget(host(0));
    final width = t.getSize(find.byType(SlidingTabStack)).width;

    await t.pumpWidget(host(2));
    await t.pump(const Duration(milliseconds: 80));
    // Going right: the new tab comes in from the right, the old one leaves
    // to the left – both visible side by side.
    final incoming = xOf(t, 'tab2 item0');
    final outgoing = xOf(t, 'tab0 item0');
    expect(incoming, inInclusiveRange(1, width - 1));
    expect(outgoing, lessThan(0));
    expect(incoming - outgoing, closeTo(width, 1));
    await t.pumpAndSettle();
    expect(xOf(t, 'tab2 item0'), 0);
    expect(find.text('tab0 item0'), findsNothing, reason: 'offstage');

    // Going left: the new tab comes from the left.
    await t.pumpWidget(host(1));
    await t.pump(const Duration(milliseconds: 80));
    expect(xOf(t, 'tab1 item0'), lessThan(0));
    expect(xOf(t, 'tab2 item0'), greaterThan(0));
    await t.pumpAndSettle();
  });

  testWidgets('every tab keeps its scroll position and state', (t) async {
    await t.pumpWidget(host(0));
    await t.drag(find.byType(ListView), const Offset(0, -1200));
    await t.pumpAndSettle();
    final offset = t
        .state<ScrollableState>(find.byType(Scrollable))
        .position
        .pixels;
    expect(offset, greaterThan(1000));

    await t.pumpWidget(host(3));
    await t.pumpAndSettle();
    await t.pumpWidget(host(0));
    await t.pumpAndSettle();
    expect(
      t.state<ScrollableState>(find.byType(Scrollable)).position.pixels,
      offset,
    );
  });

  testWidgets('"reduce motion" switches at once', (t) async {
    await t.pumpWidget(host(0, reduceMotion: true));
    await t.pumpWidget(host(2, reduceMotion: true));
    await t.pump();
    expect(xOf(t, 'tab2 item0'), 0);
    expect(find.text('tab0 item0'), findsNothing);
  });

  testWidgets('only the visible tab can start hero flights and ticks', (
    t,
  ) async {
    await t.pumpWidget(host(1));
    await t.pumpAndSettle();
    final modes = t
        .widgetList<HeroMode>(find.byType(HeroMode, skipOffstage: false))
        .toList();
    expect([for (final m in modes) m.enabled], [false, true, false, false]);
    final tickers = t
        .widgetList<TickerMode>(
          find.descendant(
            of: find.byType(SlidingTabStack),
            matching: find.byType(TickerMode, skipOffstage: false),
            skipOffstage: false,
          ),
        )
        .toList();
    expect([for (final m in tickers) m.enabled], [false, true, false, false]);
  });

  group('TabTitle', () {
    const titles = ['Bibliothek', 'Tagebuch', 'Sammlungen', 'Erinnerungen'];
    const iconKey = Key('motif');

    Widget title(int index, {bool reduceMotion = false}) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: Scaffold(
          appBar: AppBar(
            title: TabTitle(
              index: index,
              title: titles[index],
              trailing: const Icon(Icons.eco, key: iconKey, size: 18),
            ),
          ),
        ),
      ),
    );

    double iconX(WidgetTester t) => t.getTopLeft(find.byKey(iconKey)).dx;

    /// Icon positions of every frame of a switch from [from] to [to].
    Future<List<double>> track(WidgetTester t, int from, int to) async {
      await t.pumpWidget(title(from));
      await t.pumpAndSettle();
      final xs = [iconX(t)];
      await t.pumpWidget(title(to));
      for (var ms = 0; ms <= 400; ms += 16) {
        await t.pump(const Duration(milliseconds: 16));
        xs.add(iconX(t));
      }
      await t.pumpAndSettle();
      return xs;
    }

    void expectGlides(List<double> xs) {
      final total = (xs.last - xs.first).abs();
      expect(total, greaterThan(20), reason: 'titles differ in length');
      final growing = xs.last > xs.first;
      for (var i = 1; i < xs.length; i++) {
        final step = xs[i] - xs[i - 1];
        expect(
          growing ? step : -step,
          greaterThanOrEqualTo(-0.01),
          reason: 'the icon only moves one way (frame $i)',
        );
        expect(
          step.abs(),
          lessThan(total * 0.35),
          reason: 'no jump (frame $i: $step of $total)',
        );
      }
    }

    testWidgets('the motif glides when the title gets longer', (t) async {
      expectGlides(await track(t, 1, 3));
    });

    testWidgets('the motif glides when the title gets shorter', (t) async {
      expectGlides(await track(t, 3, 1));
    });

    testWidgets('the new title slides in from the side of the tab', (t) async {
      await t.pumpWidget(title(0));
      await t.pumpAndSettle();
      final restX = t.getTopLeft(find.text('Bibliothek')).dx;
      await t.pumpWidget(title(2));
      await t.pump(const Duration(milliseconds: 60));
      expect(t.getTopLeft(find.text('Sammlungen')).dx, greaterThan(restX));
      expect(t.getTopLeft(find.text('Bibliothek')).dx, lessThan(restX));
      await t.pumpAndSettle();
      expect(find.text('Bibliothek'), findsNothing);

      await t.pumpWidget(title(1));
      await t.pump(const Duration(milliseconds: 60));
      expect(t.getTopLeft(find.text('Tagebuch')).dx, lessThan(restX));
      await t.pumpAndSettle();
    });

    testWidgets('"reduce motion" switches the title at once', (t) async {
      await t.pumpWidget(title(0, reduceMotion: true));
      await t.pumpWidget(title(3, reduceMotion: true));
      await t.pump();
      expect(find.text('Bibliothek'), findsNothing);
      expect(find.text('Erinnerungen'), findsOneWidget);
    });
  });
}
