import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/season.dart';
import '../core/widgets/paper.dart';
import '../features/library/presentation/pick_external_photo_button.dart';
import '../l10n/generated/app_localizations.dart';
import 'providers.dart';
import 'tab_transitions.dart';

/// Space the tab contents keep free at the bottom for the floating pill.
const double floatingNavClearance = 96;

/// Index of the journal tab (its app bar opens the world map).
const int journalTab = 0;

/// The three tabs (Tagebuch, Sammlungen, Erinnerungen) with a shared app
/// bar (seasonal motif, settings; the journal also opens the world map) and
/// a floating pill as navigation. The pill always carries the photo button
/// that starts a new entry from the system photo picker.
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final season = Season.of(ref.watch(clockProvider)());
    final titles = [l10n.navJournal, l10n.navCollections, l10n.navMemories];

    final items = <(IconData, IconData, String)>[
      (Icons.menu_book_outlined, Icons.menu_book, l10n.navJournal),
      (
        Icons.collections_bookmark_outlined,
        Icons.collections_bookmark,
        l10n.navCollections,
      ),
      (Icons.history_edu_outlined, Icons.history_edu, l10n.navMemories),
    ];

    return Scaffold(
      appBar: AppBar(
        title: TabTitle(
          index: shell.currentIndex,
          title: titles[shell.currentIndex],
          trailing: Icon(
            season.motif,
            size: 18,
            color: context.diary.seasonMotif,
          ),
        ),
        actions: [
          if (shell.currentIndex == journalTab)
            IconButton(
              tooltip: l10n.mapOpen,
              icon: const Icon(Icons.public),
              onPressed: () => context.push('/map'),
            ),
          IconButton(
            tooltip: l10n.settingsTooltip,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: PaperBackground(
        child: Stack(
          children: [
            // The tab pages slide (see SlidingTabStack in the router).
            Positioned.fill(child: shell),
            // Only this layer follows the keyboard (it hides the pill);
            // the tabs themselves do not rebuild while it slides in.
            Positioned.fill(
              child: _FloatingControls(shell: shell, items: items),
            ),
          ],
        ),
      ),
    );
  }
}

/// The floating pill, hidden while the keyboard is open.
class _FloatingControls extends StatelessWidget {
  const _FloatingControls({required this.shell, required this.items});

  final StatefulNavigationShell shell;
  final List<(IconData, IconData, String)> items;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.viewInsetsOf(context).bottom > 0) {
      return const SizedBox.shrink();
    }
    final bottom = MediaQuery.paddingOf(context).bottom + 16;
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: bottom,
          child: Center(
            // Its own layer: the pill animates on every tab change and
            // would otherwise repaint the paper texture behind it.
            child: RepaintBoundary(
              child: _NavPill(
                selected: shell.currentIndex,
                onSelected: (i) =>
                    shell.goBranch(i, initialLocation: i == shell.currentIndex),
                items: items,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Minimal floating navigation: icons only, in a soft rounded pill. The
/// highlight glides to the chosen tab; icons change colour, size and form
/// (outlined → filled) smoothly. Behind a thin divider on the right sits the
/// photo button for a new entry.
class _NavPill extends StatelessWidget {
  const _NavPill({
    required this.selected,
    required this.onSelected,
    required this.items,
  });

  final int selected;
  final ValueChanged<int> onSelected;
  final List<(IconData, IconData, String)> items;

  static const double itemWidth = 50;
  static const double itemHeight = 44;
  static const double dividerSlotWidth = 9;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : tabSwitchDuration;
    return Material(
      color: scheme.surfaceContainerHigh,
      elevation: 6,
      shadowColor: scheme.shadow.withValues(alpha: 0.35),
      shape: StadiumBorder(
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _tabs(scheme, duration),
            _PhotoActionSlot(scheme: scheme),
          ],
        ),
      ),
    );
  }

  Widget _tabs(ColorScheme scheme, Duration duration) => SizedBox(
    width: itemWidth * items.length,
    height: itemHeight,
    child: Stack(
      children: [
        AnimatedPositioned(
          duration: duration,
          curve: tabSwitchCurve,
          left: selected * itemWidth,
          top: 0,
          width: itemWidth,
          height: itemHeight,
          child: DecoratedBox(
            decoration: ShapeDecoration(
              shape: const StadiumBorder(),
              color: scheme.primaryContainer,
            ),
          ),
        ),
        Row(
          children: [
            for (var i = 0; i < items.length; i++)
              _NavItem(
                icon: items[i].$1,
                selectedIcon: items[i].$2,
                label: items[i].$3,
                selected: i == selected,
                duration: duration,
                onTap: () => onSelected(i),
              ),
          ],
        ),
      ],
    ),
  );
}

/// Divider plus the photo button, sized like a tab item.
class _PhotoActionSlot extends StatelessWidget {
  const _PhotoActionSlot({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        width: _NavPill.dividerSlotWidth,
        height: _NavPill.itemHeight,
        child: Center(
          child: SizedBox(
            width: 1,
            height: 24,
            child: ColoredBox(color: scheme.outlineVariant),
          ),
        ),
      ),
      const SizedBox(
        width: _NavPill.itemWidth,
        height: _NavPill.itemHeight,
        child: PickExternalPhotoButton(),
      ),
    ],
  );
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.duration,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: SizedBox(
            width: _NavPill.itemWidth,
            height: _NavPill.itemHeight,
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: selected ? 1 : 0),
              duration: duration,
              curve: tabSwitchCurve,
              builder: (context, t, _) {
                final color = Color.lerp(
                  scheme.onSurfaceVariant,
                  scheme.onPrimaryContainer,
                  t,
                );
                return Transform.scale(
                  scale: 1 + 0.08 * t,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(
                        opacity: 1 - t,
                        child: Icon(icon, size: 22, color: color),
                      ),
                      Opacity(
                        opacity: t,
                        child: Icon(selectedIcon, size: 22, color: color),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
