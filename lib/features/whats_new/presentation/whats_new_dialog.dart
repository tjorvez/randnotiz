import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/season.dart';
import '../../../core/widgets/paper.dart';
import '../../../core/widgets/polaroid.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/release_notes.dart';
import 'whats_new_controller.dart';

/// Shows [notes] (newest first) as "Neu in Randnotiz". Completes when the
/// dialog is closed – by the button, Back or a tap beside it.
Future<void> showWhatsNew(BuildContext context, List<ReleaseNotes> notes) =>
    showDialog<void>(
      context: context,
      builder: (_) => WhatsNewDialog(notes: notes),
    );

/// A sheet of the diary's paper, taped down at both top corners: the title
/// in the serif with the season's motif, each new thing with its symbol, a
/// short heading and a handwritten line. Scrolls with a large system font.
class WhatsNewDialog extends ConsumerWidget {
  const WhatsNewDialog({super.key, required this.notes});

  final List<ReleaseNotes> notes;

  static const _tapeWidth = 64.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final diary = context.diary;
    final season = Season.of(ref.read(clockProvider)());
    final newest = notes.first.version;
    // Several releases at once (a long time without updating): each gets
    // its own small heading.
    final grouped = notes.length > 1;

    final sheet = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: diary.polaroidShadow,
            blurRadius: 18,
            spreadRadius: -2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Material(
          type: MaterialType.transparency,
          child: PaperBackground(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Semantics(
                          header: true,
                          child: Text(
                            l10n.whatsNewTitle(newest.label),
                            style: theme.textTheme.headlineSmall,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: ExcludeSemantics(
                          child: Icon(
                            season.motif,
                            size: 20,
                            color: diary.seasonMotif,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final release in notes) ...[
                            if (grouped)
                              _VersionHeading(
                                l10n.whatsNewVersion(release.version.label),
                                first: release == notes.first,
                              ),
                            for (final item in release.items)
                              _Item(
                                icon: item.icon,
                                title: item.title(l10n),
                                body: item.body(l10n),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.whatsNewDone),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            sheet,
            Positioned(
              top: -_tapeWidth * 0.12,
              left: -_tapeWidth * 0.2,
              child: WashiTape(
                angle: -0.6,
                color: diary.washiTape,
                width: _tapeWidth,
              ),
            ),
            Positioned(
              top: -_tapeWidth * 0.12,
              right: -_tapeWidth * 0.2,
              child: WashiTape(
                angle: 0.55,
                color: diary.washiTape,
                width: _tapeWidth,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VersionHeading extends StatelessWidget {
  const _VersionHeading(this.text, {required this.first});

  final String text;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(top: first ? 0 : 8, bottom: 10),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

/// One new thing: its symbol in a soft circle, a heading, a handwritten line.
class _Item extends StatelessWidget {
  const _Item({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: MergeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22, color: scheme.onPrimaryContainer),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: AppTheme.noteText(
                      context,
                      size: 17,
                    ).copyWith(height: 1.35, color: scheme.onSurfaceVariant),
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

/// Puts "Neu in Randnotiz" over the app once after an update, as soon as
/// nothing covers it any more ([covered]: start screen, introduction, lock).
/// The dialog lives on the app's navigator, so locking the app while it is
/// open hides it with everything else; it is back after unlocking.
class WhatsNewPrompt extends ConsumerStatefulWidget {
  const WhatsNewPrompt({
    super.key,
    required this.covered,
    required this.navigatorKey,
    required this.child,
  });

  final bool covered;
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  ConsumerState<WhatsNewPrompt> createState() => _WhatsNewPromptState();
}

class _WhatsNewPromptState extends ConsumerState<WhatsNewPrompt> {
  /// At most once per process, whatever happens around it.
  bool _asked = false;

  void _maybeShow(List<ReleaseNotes> notes) {
    if (_asked || widget.covered || notes.isEmpty) return;
    _asked = true;
    // After this frame: the app has just been uncovered.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = widget.navigatorKey.currentContext;
      if (!mounted || context == null) {
        _asked = false;
        return;
      }
      unawaited(
        showWhatsNew(
          context,
          notes,
        ).whenComplete(() => ref.read(whatsNewProvider.notifier).markSeen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    _maybeShow(ref.watch(whatsNewProvider));
    return widget.child;
  }
}
