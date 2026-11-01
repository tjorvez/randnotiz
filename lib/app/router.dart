import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/backup/presentation/backup_screen.dart';
import '../features/collections/presentation/collection_screen.dart';
import '../features/collections/presentation/collections_screen.dart';
import '../features/intro/presentation/intro_controller.dart';
import '../features/intro/presentation/intro_screen.dart';
import '../features/journal/presentation/journal_screen.dart';
import '../features/map/presentation/map_screen.dart';
import '../features/memories/presentation/memories_screen.dart';
import '../features/notes/presentation/note_editor_screen.dart';
import '../features/notes/presentation/open_note.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/tags/presentation/tag_management_screen.dart';
import 'covered_page.dart';
import 'home_shell.dart';
import 'tab_transitions.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/journal',
    routes: [
      StatefulShellRoute(
        builder: (context, state, shell) =>
            CoveredPageInsets(child: HomeShell(shell: shell)),
        navigatorContainerBuilder: _branchStack,
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/journal',
                builder: (_, _) => const JournalScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/collections',
                builder: (_, _) => const CollectionsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/memories',
                builder: (_, _) => const MemoriesScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/note/:assetId',
        pageBuilder: (context, state) {
          final extra = state.extra is NoteRouteExtra
              ? state.extra! as NoteRouteExtra
              : const NoteRouteExtra();
          return NotePage(
            key: state.pageKey,
            entrance: extra.entrance,
            reduceMotion: MediaQuery.disableAnimationsOf(context),
            child: NoteEditorScreen(
              assetId: state.pathParameters['assetId']!,
              collectionId: int.tryParse(
                state.uri.queryParameters['collection'] ?? '',
              ),
              heroTag: extra.heroTag,
            ),
          );
        },
      ),
      GoRoute(path: '/map', builder: (_, _) => const MapScreen()),
      GoRoute(
        path: '/collection/:id',
        builder: (context, state) => CoveredPageInsets(
          child: CollectionScreen(
            collectionId: int.parse(state.pathParameters['id']!),
          ),
        ),
      ),
      settingsRoute(),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

/// Settings with their sub-pages (Stimmungen, Sicherung, Einführung).
GoRoute settingsRoute() => GoRoute(
  path: '/settings',
  builder: (_, _) => const SettingsScreen(),
  routes: [
    GoRoute(path: 'tags', builder: (_, _) => const TagManagementScreen()),
    GoRoute(
      path: 'backup',
      builder: (context, state) {
        final query = state.uri.queryParameters;
        return BackupScreen(
          restoreFirst: query['restore'] == '1',
          // Coming from the introduction: after restoring, show the
          // entries that came back.
          onRestored: query['from'] == 'intro'
              ? () => GoRouter.of(context).go('/journal')
              : null,
        );
      },
    ),
    // "Einführung ansehen": the introduction again, flag untouched.
    GoRoute(
      path: 'intro',
      builder: (context, _) => IntroScreen(
        onAction: (action) {
          final backup = backupLocationAfterIntro(action);
          if (backup == null) {
            context.pop();
          } else {
            context.pushReplacement(backup);
          }
        },
      ),
    ),
  ],
);

/// Where an introduction action leads: the backup screen (with the restore
/// path first for [IntroAction.restoreBackup]), or null for the journal.
String? backupLocationAfterIntro(IntroAction action) => switch (action) {
  IntroAction.setUpBackup => '/settings/backup?from=intro',
  IntroAction.restoreBackup => '/settings/backup?from=intro&restore=1',
  IntroAction.later => null,
};

/// After the first-start introduction: the journal, with the backup screen
/// on top if one of the backup actions was chosen – going back from it
/// leads to the journal.
void startAfterIntro(GoRouter router, IntroAction action) {
  router.go('/journal');
  final backup = backupLocationAfterIntro(action);
  if (backup != null) unawaited(router.push(backup));
}

/// The note page: fades in while rising a few pixels; the tapped polaroid
/// flies in as a shared element (see `PolaroidHero`). Moving to the
/// next/previous entry of a collection slides sideways instead. Only opacity
/// and translation are animated (both cheap for the GPU). With "reduce
/// motion" the page only fades briefly and nothing flies.
class NotePage<T> extends CustomTransitionPage<T> {
  NotePage({
    super.key,
    required Widget child,
    NoteEntrance entrance = NoteEntrance.rise,
    bool reduceMotion = false,
  }) : super(
         child: reduceMotion ? HeroMode(enabled: false, child: child) : child,
         transitionDuration: reduceMotion
             ? const Duration(milliseconds: 150)
             : const Duration(milliseconds: 360),
         reverseTransitionDuration: reduceMotion
             ? const Duration(milliseconds: 120)
             : const Duration(milliseconds: 300),
         transitionsBuilder: (context, animation, secondary, child) {
           final fade = CurvedAnimation(
             parent: animation,
             curve: const Interval(0, 0.7, curve: Curves.easeOut),
             reverseCurve: const Interval(0.25, 1, curve: Curves.easeIn),
           );
           if (MediaQuery.disableAnimationsOf(context)) {
             return FadeTransition(opacity: fade, child: child);
           }
           final begin = switch (entrance) {
             NoteEntrance.rise => const Offset(0, 0.035),
             NoteEntrance.next => const Offset(0.18, 0),
             NoteEntrance.previous => const Offset(-0.18, 0),
           };
           final move = CurvedAnimation(
             parent: animation,
             curve: Curves.easeOutQuart,
             reverseCurve: Curves.easeInCubic,
           );
           return FadeTransition(
             opacity: fade,
             child: SlideTransition(
               position: Tween(begin: begin, end: Offset.zero).animate(move),
               child: child,
             ),
           );
         },
       );
}

/// The tabs slide horizontally when switching (see [SlidingTabStack]).
Widget _branchStack(
  BuildContext context,
  StatefulNavigationShell shell,
  List<Widget> children,
) => SlidingTabStack(currentIndex: shell.currentIndex, children: children);
