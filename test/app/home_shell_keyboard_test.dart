import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:randnotiz/app/home_shell.dart';
import 'package:randnotiz/core/theme/app_theme.dart';
import 'package:randnotiz/core/theme/season.dart';
import 'package:randnotiz/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('the navigation pill does not ride up on the keyboard', (
    t,
  ) async {
    final router = GoRouter(
      initialLocation: '/a',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (_, _, shell) => HomeShell(shell: shell),
          branches: [
            for (final p in ['a', 'b', 'c'])
              StatefulShellBranch(
                routes: [
                  GoRoute(path: '/$p', builder: (_, _) => const TextField()),
                ],
              ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    t.view.physicalSize = const Size(400, 800);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);

    await t.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.build(Brightness.light, Season.autumn),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
        ),
      ),
    );
    await t.pump();
    final pill = find.byIcon(Icons.menu_book);
    expect(pill, findsOneWidget);
    final resting = t.getCenter(pill);

    t.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(t.view.resetViewInsets);
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));

    // Either it stays where it was (behind the keyboard) or it is gone –
    // but it never sits on top of the keyboard.
    final shown = pill.evaluate().isNotEmpty;
    if (shown) expect(t.getCenter(pill), resting);
    expect(shown, isFalse, reason: 'hidden while the keyboard is open');
  });
}
