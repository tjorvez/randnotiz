import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/home_shell.dart';
import '../../../app/providers.dart';
import '../../../core/format/formatters.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/polaroid.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../notes/domain/note.dart';
import '../../notes/presentation/note_photo.dart';
import '../../notes/presentation/open_note.dart';
import '../../weather/presentation/weather_ui.dart';
import '../domain/memory_feed.dart';

/// One random order per app session: the "more" part of the slider stays
/// the same while the app runs, and is new the next time.
final memorySessionSeedProvider = Provider<int>(
  (ref) => DateTime.now().microsecondsSinceEpoch & 0x7FFFFFFF,
);

final memoryFeedProvider = Provider.autoDispose<AsyncValue<List<MemoryPage>>>((
  ref,
) {
  final today = ref.watch(clockProvider)();
  final seed = ref.watch(memorySessionSeedProvider);
  return ref
      .watch(allNotesProvider)
      .whenData((notes) => buildMemoryFeed(notes, today, seed: seed));
});

/// Tab "Erinnerungen": a full-height slider, one memory per page, swiped
/// vertically and snapping. First today's calendar day in earlier years,
/// then the days around it, then everything else in a random order.
///
/// Only the visible page and its two neighbours are built (the PageView's
/// implicit scrolling); the photo after the next one is decoded ahead, and
/// photos of pages far behind are released from the image cache.
class MemoriesScreen extends ConsumerStatefulWidget {
  const MemoriesScreen({super.key});

  @override
  ConsumerState<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends ConsumerState<MemoriesScreen> {
  final _pages = PageController();
  List<MemoryPage> _feed = const [];

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  /// Decoded size of the photos in the slider (the same for every page, so
  /// pre-loading and the page use the same image cache entry).
  int _cacheWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return (min(width * 0.86, 440) * MediaQuery.devicePixelRatioOf(context))
        .round();
  }

  ImageProvider? _imageFor(NoteSummary note, int cacheWidth) {
    final file = note.thumbnailFile;
    if (file == null) return null;
    return NotePhoto.storedCopyProvider(
      ref.read(thumbnailStoreProvider),
      file,
      cacheWidth: cacheWidth,
    );
  }

  void _onPageChanged(int index) {
    final cacheWidth = _cacheWidth(context);
    // The next page is already built; decode the one after it, too.
    for (final i in [index + 1, index + 2]) {
      if (i >= _feed.length) break;
      final image = _imageFor(_feed[i].note, cacheWidth);
      if (image != null) precacheImage(image, context, onError: (_, _) {});
    }
    // Let go of photos of pages far behind (they are rebuilt if needed).
    for (final i in [index - 3, index + 4]) {
      if (i < 0 || i >= _feed.length) continue;
      final image = _imageFor(_feed[i].note, cacheWidth);
      if (image != null) imageCache.evict(image);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ref
        .watch(memoryFeedProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(child: Text(l10n.errorGeneric)),
          data: (feed) {
            _feed = feed;
            if (feed.isEmpty) {
              return EmptyState(
                icon: Icons.history_edu_outlined,
                title: l10n.memoriesEmptyTitle,
                body: l10n.memoriesEmptyBody,
              );
            }
            final indexOfId = {for (final (i, p) in feed.indexed) p.note.id: i};
            final cacheWidth = _cacheWidth(context);
            return PageView.builder(
              controller: _pages,
              scrollDirection: Axis.vertical,
              // Keeps exactly one page before and after the visible one.
              allowImplicitScrolling: true,
              itemCount: feed.length,
              onPageChanged: _onPageChanged,
              findChildIndexCallback: (key) {
                return indexOfId[(key as ValueKey<int>).value];
              },
              itemBuilder: (context, i) => MemoryPageView(
                key: ValueKey(feed[i].note.id),
                page: feed[i],
                cacheWidth: cacheWidth,
                showSwipeHint: i == 0 && feed.length > 1,
              ),
            );
          },
        );
  }
}

/// One memory: a large polaroid with its title, how long ago it was, the
/// date, place and weather, the Stimmungen and the beginning of the note.
/// Tapping opens the note; the polaroid flies into it.
class MemoryPageView extends ConsumerWidget {
  const MemoryPageView({
    super.key,
    required this.page,
    required this.cacheWidth,
    this.showSwipeHint = false,
  });

  final MemoryPage page;
  final int cacheWidth;
  final bool showSwipeHint;

  static const double _dividerHeight = 34;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final today = ref.watch(clockProvider)();
    final note = page.note;
    final heroTag = NoteHeroTag('memories', note.assetId);
    final muted = theme.colorScheme.onSurfaceVariant;

    final when = switch (page.section) {
      MemorySection.onThisDay ||
      MemorySection.aroundThisDay => l10n.yearsAgo(page.yearsAgo!),
      MemorySection.more => Fmt.ago(l10n, note.date, today),
    };
    final offset = page.dayOffset;
    final anniversary = offset > 0
        ? l10n.memoriesAnniversaryIn(offset)
        : offset < 0
        ? l10n.memoriesAnniversaryAgo(-offset)
        : null;
    final excerpt = note.preview.trim();

    return Semantics(
      button: true,
      label: [
        when,
        Fmt.longDate(note.date),
        ?note.title,
        l10n.memoriesOpen,
      ].join(', '),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => openNote(context, note.assetId, heroTag: heroTag),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, floatingNavClearance),
          child: Column(
            children: [
              SizedBox(
                height: _dividerHeight,
                child: page.startsSection
                    ? _SectionDivider(section: page.section)
                    : null,
              ),
              Text(
                when,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 2),
              Text(
                [Fmt.longDateWithWeekday(note.date), ?anniversary].join(' · '),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: AppFonts.serif,
                  fontSize: 16,
                  color: muted,
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final aspect = PolaroidGeometry.photoAspectOrSquare(
                      note.photoAspect,
                    );
                    final cardAspect = PolaroidGeometry.cardAspect(aspect);
                    final width = min(
                      min(constraints.maxWidth * 0.86, 440.0),
                      (constraints.maxHeight - 18) * cardAspect,
                    );
                    return Center(
                      child: SizedBox(
                        width: max(width, 80),
                        child: Polaroid(
                          tilt: Polaroid.tiltFor(note.assetId),
                          title: note.title,
                          photoAspect: aspect,
                          hero: PolaroidHero(tag: heroTag),
                          image: NotePhoto(
                            assetId: note.assetId,
                            thumbnailFile: note.thumbnailFile,
                            preferStoredCopy: true,
                            cacheWidth: cacheWidth,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              _MetaLine(note: note),
              if (note.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  alignment: WrapAlignment.center,
                  children: [for (final t in note.tags) TagLabel(tag: t)],
                ),
              ],
              if (excerpt.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  excerpt,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTheme.noteText(context, size: 18),
                ),
              ],
              if (showSwipeHint) _SwipeHint(label: l10n.memoriesSwipeHint),
            ],
          ),
        ),
      ),
    );
  }
}

/// Place and weather in one quiet line (nothing if neither is known).
class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.note});

  final NoteSummary note;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    final weather = note.weather;
    final style = TextStyle(fontSize: 14, color: color);
    if (note.placeName == null && weather == null) {
      return const SizedBox.shrink();
    }
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      children: [
        if (note.placeName != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.place_outlined, size: 16, color: color),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  note.placeName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style,
                ),
              ),
            ],
          ),
        if (weather != null)
          Tooltip(
            message: weatherLabel(l10n, weather),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(weatherIcon(weather.kind), size: 16, color: color),
                const SizedBox(width: 3),
                Text(
                  weather.temperatureC != null
                      ? l10n.weatherTemperature(
                          Fmt.temperature(weather.temperatureC!),
                        )
                      : l10n.weatherKind(weather.kind.name),
                  style: style,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// A quiet label with hairlines where a part of the slider begins.
class _SectionDivider extends StatelessWidget {
  const _SectionDivider({required this.section});

  final MemorySection section;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final line = Expanded(
      child: Divider(color: theme.colorScheme.outlineVariant, thickness: 1),
    );
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        children: [
          line,
          ConstrainedBox(
            // The label keeps its natural width (up to 70 %), the two lines
            // share the rest equally – so it is always centred.
            constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.7),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                switch (section) {
                  MemorySection.onThisDay => l10n.memoriesSectionOnThisDay,
                  MemorySection.aroundThisDay => l10n.memoriesSectionAround,
                  MemorySection.more => l10n.memoriesSectionMore,
                },
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.secondary,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
          line,
        ],
      ),
    );
  }
}

class _SwipeHint extends StatelessWidget {
  const _SwipeHint({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outline;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.keyboard_arrow_up, size: 18, color: color),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
