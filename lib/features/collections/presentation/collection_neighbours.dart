import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/format/formatters.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/polaroid.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../notes/domain/note.dart';
import '../../notes/presentation/note_photo.dart';
import '../../notes/presentation/open_note.dart';
import '../domain/collection.dart';
import 'collection_providers.dart';

/// Below a note: the previous and next entry of each collection the note
/// belongs to. The collection the note was opened from comes first.
class CollectionNeighboursSection extends ConsumerWidget {
  const CollectionNeighboursSection({
    super.key,
    required this.noteId,
    this.preferredCollectionId,
  });

  final int noteId;
  final int? preferredCollectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref.watch(noteCollectionIdsProvider(noteId)).value ?? const {};
    if (ids.isEmpty) return const SizedBox.shrink();
    final collections =
        <Collection>[
          for (final c
              in ref.watch(collectionsProvider).value ?? const <Collection>[])
            if (ids.contains(c.id)) c,
        ]..sort((a, b) {
          if (a.id == preferredCollectionId) return -1;
          if (b.id == preferredCollectionId) return 1;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
    return Column(
      children: [
        for (final c in collections)
          _CollectionNeighbours(collection: c, noteId: noteId),
      ],
    );
  }
}

class _CollectionNeighbours extends ConsumerWidget {
  const _CollectionNeighbours({required this.collection, required this.noteId});

  final Collection collection;
  final int noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final entries = ref.watch(collectionEntriesProvider(collection.id)).value;
    final around = entries == null
        ? null
        : CollectionNeighbours.of(entries, noteId);
    if (around == null || around.total < 2) return const SizedBox.shrink();

    void go(NoteSummary target, NoteEntrance entrance) => openNote(
      context,
      target.assetId,
      collectionId: collection.id,
      entrance: entrance,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.collections_bookmark_outlined,
                size: 16,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.collectionNeighboursTitle(
                    collection.name,
                    around.position,
                    around.total,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontFamily: AppFonts.serif,
                    fontSize: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: around.previous == null
                      ? _Edge(text: l10n.collectionStart)
                      : _NeighbourCard(
                          entry: around.previous!,
                          label: l10n.collectionPrevious,
                          forward: false,
                          onTap: () =>
                              go(around.previous!, NoteEntrance.previous),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: around.next == null
                      ? _Edge(text: l10n.collectionEnd)
                      : _NeighbourCard(
                          entry: around.next!,
                          label: l10n.collectionNext,
                          forward: true,
                          onTap: () => go(around.next!, NoteEntrance.next),
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

class _NeighbourCard extends StatelessWidget {
  const _NeighbourCard({
    required this.entry,
    required this.label,
    required this.forward,
    required this.onTap,
  });

  final NoteSummary entry;
  final String label;
  final bool forward;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final cacheWidth = (48 * MediaQuery.devicePixelRatioOf(context)).round();
    final photo = SizedBox(
      width: 42,
      child: Polaroid(
        tilt: Polaroid.tiltFor(entry.assetId),
        tape: false,
        image: NotePhoto(
          assetId: entry.assetId,
          thumbnailFile: entry.thumbnailFile,
          preferStoredCopy: true,
          cacheWidth: cacheWidth,
        ),
      ),
    );
    final text = Expanded(
      child: Column(
        crossAxisAlignment: forward
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!forward) Icon(Icons.chevron_left, size: 16, color: muted),
              Text(label, style: TextStyle(fontSize: 12, color: muted)),
              if (forward) Icon(Icons.chevron_right, size: 16, color: muted),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            Fmt.shortDate(entry.date),
            maxLines: 1,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: AppFonts.serif,
              fontSize: 15,
            ),
          ),
          if (entry.preview.trim().isNotEmpty)
            Text(
              entry.preview.trim().split('\n').first,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: forward ? TextAlign.end : TextAlign.start,
              style: AppTheme.noteText(context, size: 15).copyWith(height: 1.3),
            ),
        ],
      ),
    );
    return Semantics(
      button: true,
      label: '$label, ${Fmt.longDate(entry.date)}',
      excludeSemantics: true,
      child: Material(
        color: theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: forward
                  ? [text, const SizedBox(width: 10), photo]
                  : [photo, const SizedBox(width: 10), text],
            ),
          ),
        ),
      ),
    );
  }
}

class _Edge extends StatelessWidget {
  const _Edge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Theme.of(context).colorScheme.outlineVariant,
        style: BorderStyle.solid,
      ),
    ),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: AppTheme.noteText(
        context,
        size: 15,
      ).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
    ),
  );
}
