import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/tab_transitions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/season.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/paper.dart';
import '../../../core/widgets/polaroid.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../backup/domain/backup_service.dart';
import '../../backup/presentation/backup_controller.dart';
import 'intro_controller.dart';

/// Three pages that explain in a few seconds that the diary is private, how
/// it is locked and how the encrypted backup works. Swipe or "Weiter";
/// "Überspringen" at any time. Shows no user data – on the first start it
/// may cover the app before unlocking (see `LockGate.cover`).
///
/// Every statement here must hold against PRIVACY.md: nothing is promised
/// that the fine print would take back.
class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key, required this.onAction});

  /// Called once with the chosen action ("Überspringen" counts as
  /// [IntroAction.later]).
  final ValueChanged<IntroAction> onAction;

  static const pageCount = 3;

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen> {
  final _pages = PageController();
  var _page = 0;
  var _done = false;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _choose(IntroAction action) {
    if (_done) return;
    _done = true;
    widget.onAction(action);
  }

  void _next() {
    final target = (_page + 1).clamp(0, IntroScreen.pageCount - 1);
    if (MediaQuery.disableAnimationsOf(context)) {
      _pages.jumpToPage(target);
    } else {
      unawaited(
        _pages.animateToPage(
          target,
          duration: tabSwitchDuration,
          curve: tabSwitchCurve,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final last = _page == IntroScreen.pageCount - 1;
    final backupAvailable =
        ref.watch(backupStatusProvider.select((s) => s.phase)) !=
        BackupPhase.notConfigured;
    final season = Season.of(ref.read(clockProvider)());

    final pages = <Widget>[
      _IntroPage(
        index: 0,
        controller: _pages,
        season: season,
        illustration: const _Illustration.logo(),
        caption: l10n.introPrivateCaption,
        title: l10n.introPrivateTitle,
        body: [Text(l10n.introPrivateBody)],
      ),
      _IntroPage(
        index: 1,
        controller: _pages,
        season: season,
        illustration: const _Illustration(Icons.fingerprint),
        caption: l10n.introLockCaption,
        title: l10n.introLockTitle,
        body: [
          Text(l10n.introLockBody),
          if (!kReleaseMode) _FinePrint(l10n.introLockDebug),
          _FinePrint(l10n.introLockWidget),
        ],
      ),
      _IntroPage(
        index: 2,
        controller: _pages,
        season: season,
        illustration: const _Illustration(Icons.enhanced_encryption_outlined),
        caption: l10n.introBackupCaption,
        title: l10n.introBackupTitle,
        body: [
          Text(l10n.introBackupBody),
          _OnlineNote(title: l10n.introOnlineTitle, body: l10n.introOnlineBody),
        ],
      ),
    ];

    return Material(
      child: PaperBackground(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                  child: TextButton(
                    onPressed: () => _choose(IntroAction.later),
                    child: Text(l10n.introSkip),
                  ),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pages,
                  onPageChanged: (i) => setState(() => _page = i),
                  children: pages,
                ),
              ),
              // Pages 1–2: dots and "Weiter". Last page: the choices stay
              // in view below the (scrolling) text.
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _PageDots(
                            page: _page,
                            count: IntroScreen.pageCount,
                          ),
                        ),
                        if (!last)
                          FilledButton(
                            onPressed: _next,
                            child: Text(l10n.introNext),
                          ),
                      ],
                    ),
                    if (last) ...[
                      const SizedBox(height: 12),
                      _Actions(
                        backupAvailable: backupAvailable,
                        onAction: _choose,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One page: a polaroid with a symbol, a handwritten caption on its rim,
/// the title and the text. Scrolls if the system font is large. While
/// swiping, the polaroid drifts a little slower than the page and the text
/// fades (no movement with "reduce motion").
class _IntroPage extends StatelessWidget {
  const _IntroPage({
    required this.index,
    required this.controller,
    required this.season,
    required this.illustration,
    required this.caption,
    required this.title,
    required this.body,
  });

  final int index;
  final PageController controller;
  final Season season;
  final Widget illustration;
  final String caption;
  final String title;
  final List<Widget> body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diary = context.diary;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final width = MediaQuery.sizeOf(context).width;
    final polaroidWidth = (width * 0.46).clamp(120.0, 220.0);

    Widget drifting(Widget child, {required double shift, double fade = 0}) {
      if (reduceMotion) return child;
      return AnimatedBuilder(
        animation: controller,
        child: child,
        builder: (context, child) {
          final page =
              controller.hasClients && controller.position.haveDimensions
              ? controller.page ?? controller.initialPage.toDouble()
              : controller.initialPage.toDouble();
          final delta = (page - index).clamp(-1.0, 1.0);
          return Opacity(
            opacity: (1 - delta.abs() * fade).clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(delta * shift, 0),
              child: child,
            ),
          );
        },
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Center(
            child: drifting(
              shift: width * 0.35,
              ExcludeSemantics(
                child: SizedBox(
                  width: polaroidWidth,
                  child: Polaroid(
                    image: illustration,
                    title: caption,
                    tilt: const [-2.2, 1.6, -1.2][index],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          drifting(
            shift: 0,
            fade: 0.9,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          title,
                          style: theme.textTheme.headlineSmall,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Icon(
                        season.motif,
                        size: 20,
                        color: diary.seasonMotif,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DefaultTextStyle.merge(
                  style: AppTheme.noteText(context, size: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final part in body) ...[
                        part,
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The "photo" of a page's polaroid: a symbol on the accent colour.
class _Illustration extends StatelessWidget {
  const _Illustration(IconData this.icon);
  const _Illustration.logo() : icon = null;

  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.primaryContainer,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest.shortestSide * 0.46;
          return Center(
            child: icon == null
                ? AppLogo(size: size, color: scheme.onPrimaryContainer)
                : Icon(icon, size: size, color: scheme.onPrimaryContainer),
          );
        },
      ),
    );
  }
}

/// A smaller, quieter line under the text.
class _FinePrint extends StatelessWidget {
  const _FinePrint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.bodyMedium
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
  );
}

/// The honest addition on the backup page: what does go online.
class _OnlineNote extends StatelessWidget {
  const _OnlineNote({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.wifi, size: 20, color: scheme.onSurfaceVariant),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The last page's choices. Without an OAuth client in the build the
/// backup is unavailable – then there is only one way on.
class _Actions extends StatelessWidget {
  const _Actions({required this.backupAvailable, required this.onAction});

  final bool backupAvailable;
  final ValueChanged<IntroAction> onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!backupAvailable) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FinePrint(l10n.introBackupUnavailable),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => onAction(IntroAction.later),
            child: Text(l10n.introStart),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () => onAction(IntroAction.setUpBackup),
          icon: const Icon(Icons.cloud_upload_outlined),
          label: Text(l10n.introSetUpBackup),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => onAction(IntroAction.restoreBackup),
          icon: const Icon(Icons.settings_backup_restore),
          label: Text(l10n.introHaveBackup),
        ),
        TextButton(
          onPressed: () => onAction(IntroAction.later),
          child: Text(l10n.introLater),
        ),
      ],
    );
  }
}

/// "Seite 2 von 3" as dots; the current one is wider.
class _PageDots extends StatelessWidget {
  const _PageDots({required this.page, required this.count});

  final int page;
  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : tabSwitchDuration;
    return Semantics(
      label: AppLocalizations.of(context).introPageLabel(page + 1, count),
      excludeSemantics: true,
      child: Row(
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: duration,
              curve: tabSwitchCurve,
              margin: const EdgeInsets.only(right: 8),
              width: i == page ? 22 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == page ? scheme.primary : scheme.outline,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
        ],
      ),
    );
  }
}
