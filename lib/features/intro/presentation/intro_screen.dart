import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_locale.dart';
import '../../../app/providers.dart';
import '../../../app/start_splash.dart';
import '../../../app/tab_transitions.dart';
import '../../../core/l10n/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/season.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/paper.dart';
import '../../../core/widgets/polaroid.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../backup/domain/backup_service.dart';
import '../../backup/presentation/backup_controller.dart';
import '../../settings/presentation/settings_controller.dart';
import 'intro_controller.dart';
import 'intro_scenes.dart';

/// The first start: a welcome with the claim and the choice of language,
/// the optional encrypted backup, then a short tour with little animations
/// of how the app is used. Swipe or "Continue"; "Skip" at any time.
///
/// The backup choice is only remembered here – the backup screen opens
/// after the tour. Shows no user data, so on the first start it may cover
/// the app before unlocking (see `LockGate.cover`).
///
/// Every statement here must hold against PRIVACY.md: nothing is promised
/// that the fine print would take back.
class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key, required this.onAction});

  /// Called once at the end with the backup choice ("Skip" keeps the
  /// choice made so far, [IntroAction.later] if none).
  final ValueChanged<IntroAction> onAction;

  /// Welcome, backup, four tour pages.
  static final pageCount = 2 + _tour.length;

  static const _tour = IntroScene.values;

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen> {
  final _pages = PageController();
  var _page = 0;
  var _done = false;

  /// The backup choice of the second page.
  var _backup = IntroAction.later;

  static const _cloudPage = 1;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _finish() {
    if (_done) return;
    _done = true;
    widget.onAction(_backup);
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

  void _chooseBackup(IntroAction choice) {
    setState(() => _backup = choice);
    _next();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final last = _page == IntroScreen.pageCount - 1;
    final backupAvailable =
        ref.watch(backupStatusProvider.select((s) => s.phase)) !=
        BackupPhase.notConfigured;
    final today = ref.read(clockProvider)();
    final season = Season.of(today);

    final pages = <Widget>[
      const _WelcomePage(),
      _CloudPage(season: season),
      for (final (i, scene) in IntroScreen._tour.indexed)
        _TourPage(
          scene: scene,
          active: _page == 2 + i,
          today: today,
          season: season,
          last: scene == IntroScreen._tour.last,
        ),
    ];

    final Widget actions;
    if (_page == _cloudPage) {
      actions = _CloudActions(
        available: backupAvailable,
        chosen: _backup,
        onChoose: _chooseBackup,
      );
    } else if (last) {
      // The claim sees the person off, always in view above the way on.
      actions = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.3,
            child: const _Claim(size: 22),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _finish,
            child: Text(switch (_backup) {
              IntroAction.setUpBackup => l10n.introStartBackup,
              IntroAction.restoreBackup => l10n.introStartRestore,
              IntroAction.later => l10n.introStart,
            }),
          ),
        ],
      );
    } else {
      actions = const SizedBox.shrink();
    }

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
                    onPressed: _finish,
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
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        // Shrinks rather than pushing the button off (large
                        // fonts, long words).
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: _PageDots(
                              page: _page,
                              count: IntroScreen.pageCount,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (!last && _page != _cloudPage)
                          FilledButton(
                            onPressed: _next,
                            child: Text(l10n.introNext),
                          ),
                      ],
                    ),
                    if (_page == _cloudPage || last) ...[
                      const SizedBox(height: 12),
                      actions,
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

/// A page's column: centred in the space, scrolls if the system font is
/// large.
class _PageBody extends StatelessWidget {
  const _PageBody({required this.children});

  final List<Widget> children;

  static const _padding = EdgeInsets.fromLTRB(28, 4, 28, 16);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      padding: _padding,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight - _padding.vertical,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    ),
  );
}

/// The title with the season's little motif beside it.
class _Title extends StatelessWidget {
  const _Title(this.text, {required this.season});

  final String text;
  final Season season;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(text, style: theme.textTheme.headlineSmall),
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Icon(season.motif, size: 20, color: context.diary.seasonMotif),
        ),
      ],
    );
  }
}

/// The claim, handwritten in the accent colour.
class _Claim extends StatelessWidget {
  const _Claim({this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      child: Transform.rotate(
        angle: -0.02,
        child: Text(
          AppLocalizations.of(context).claim,
          textAlign: TextAlign.center,
          style: AppTheme.noteText(
            context,
            size: size,
          ).copyWith(color: scheme.primary, height: 1.3),
        ),
      ),
    );
  }
}

// --- 1: welcome and language -------------------------------------------------

class _WelcomePage extends ConsumerStatefulWidget {
  const _WelcomePage();

  @override
  ConsumerState<_WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends ConsumerState<_WelcomePage>
    with SingleTickerProviderStateMixin {
  /// The logo draws itself once, then the words appear.
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _entrance.value = 1;
    } else if (_entrance.value == 0 &&
        !_entrance.isAnimating &&
        // On the first start: after the start screen has gone.
        !StartSplash.coversOf(context)) {
      unawaited(_entrance.forward());
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final showing = ref.watch(appLanguageProvider);

    final logo = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0, 0.6, curve: Curves.easeInOut),
    );
    final words = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.45, 1, curve: Curves.easeOut),
    );

    return _PageBody(
      children: [
        Center(
          child: AnimatedBuilder(
            animation: logo,
            builder: (context, _) =>
                ExcludeSemantics(child: AppLogo(size: 132, drawn: logo.value)),
          ),
        ),
        FadeTransition(
          opacity: words,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  l10n.introWelcome,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontFamily: AppFonts.serif,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const _Claim(),
              const SizedBox(height: 16),
              Text(
                l10n.introWelcomeBody,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                l10n.introLanguageTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final language in AppLanguage.translated)
                    ChoiceChip(
                      label: Text(language.nativeName!),
                      selected: language == showing,
                      onSelected: (_) => unawaited(
                        ref
                            .read(settingsProvider.notifier)
                            .setLanguage(language),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --- 2: privacy and the optional backup --------------------------------------

class _CloudPage extends ConsumerWidget {
  const _CloudPage({required this.season});

  final Season season;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final available =
        ref.watch(backupStatusProvider.select((s) => s.phase)) !=
        BackupPhase.notConfigured;
    final width = (MediaQuery.sizeOf(context).width * 0.4).clamp(110.0, 180.0);
    return _PageBody(
      children: [
        Center(
          child: ExcludeSemantics(
            child: SizedBox(
              width: width,
              child: Polaroid(
                image: ColoredBox(
                  color: scheme.primaryContainer,
                  child: LayoutBuilder(
                    builder: (context, constraints) => Icon(
                      Icons.enhanced_encryption_outlined,
                      size: constraints.biggest.shortestSide * 0.46,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
                title: l10n.introCloudCaption,
                tilt: -2.2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _Title(l10n.introCloudTitle, season: season),
        const SizedBox(height: 12),
        DefaultTextStyle.merge(
          style: AppTheme.noteText(context, size: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.introCloudBody),
              const SizedBox(height: 12),
              _FinePrint(l10n.introCloudKeys),
              const SizedBox(height: 12),
              _OnlineNote(
                title: l10n.introOnlineTitle,
                body: l10n.introOnlineBody,
              ),
              const SizedBox(height: 20),
              if (available) ...[
                Text(
                  l10n.introCloudQuestion,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                _FinePrint(l10n.introCloudAfterTour),
              ] else
                _FinePrint(l10n.introBackupUnavailable),
            ],
          ),
        ),
      ],
    );
  }
}

/// The backup choices below the backup page; the chosen one has a tick
/// (when coming back to the page). Without an OAuth client in the build
/// the backup is unavailable – then there is only one way on.
class _CloudActions extends StatelessWidget {
  const _CloudActions({
    required this.available,
    required this.chosen,
    required this.onChoose,
  });

  final bool available;
  final IntroAction chosen;
  final ValueChanged<IntroAction> onChoose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!available) {
      return FilledButton(
        onPressed: () => onChoose(IntroAction.later),
        child: Text(l10n.introNext),
      );
    }
    Icon mark(IntroAction action, IconData icon) =>
        Icon(chosen == action ? Icons.check : icon);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () => onChoose(IntroAction.setUpBackup),
          icon: mark(IntroAction.setUpBackup, Icons.cloud_upload_outlined),
          label: Text(l10n.introSetUpBackup),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => onChoose(IntroAction.restoreBackup),
          icon: mark(IntroAction.restoreBackup, Icons.settings_backup_restore),
          label: Text(l10n.introHaveBackup),
        ),
        TextButton(
          onPressed: () => onChoose(IntroAction.later),
          child: Text(l10n.introNoCloud),
        ),
      ],
    );
  }
}

// --- 3–6: the tour ------------------------------------------------------------

class _TourPage extends StatelessWidget {
  const _TourPage({
    required this.scene,
    required this.active,
    required this.today,
    required this.season,
    required this.last,
  });

  final IntroScene scene;
  final bool active;
  final DateTime today;
  final Season season;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (title, body) = switch (scene) {
      IntroScene.photo => (l10n.introPhotoTitle, l10n.introPhotoBody),
      IntroScene.write => (l10n.introWriteTitle, l10n.introWriteBody),
      IntroScene.journal => (l10n.introJournalTitle, l10n.introJournalBody),
      IntroScene.memories => (l10n.introMemoriesTitle, l10n.introMemoriesBody),
    };
    return _PageBody(
      children: [
        const SizedBox(height: 4),
        IntroSceneView(scene: scene, active: active, today: today),
        const SizedBox(height: 24),
        _Title(title, season: season),
        const SizedBox(height: 12),
        DefaultTextStyle.merge(
          style: AppTheme.noteText(context, size: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(body),
              if (last) ...[
                const SizedBox(height: 12),
                _FinePrint(l10n.introLock),
                if (!kReleaseMode) ...[
                  const SizedBox(height: 8),
                  _FinePrint(l10n.introLockDebug),
                ],
              ],
            ],
          ),
        ),
      ],
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

/// "Page 2 of 6" as dots; the current one is wider.
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
      // Its own node: TalkBack reads it apart from the words around it.
      container: true,
      label: AppLocalizations.of(context).introPageLabel(page + 1, count),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: duration,
              curve: tabSwitchCurve,
              margin: const EdgeInsets.only(right: 6),
              width: i == page ? 20 : 7,
              height: 7,
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
