import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/format/formatters.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/paper.dart';
import '../../../core/widgets/polaroid.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../journal/presentation/journal_screen.dart';
import '../../notes/domain/note.dart';
import '../../notes/presentation/note_photo.dart';
import 'collection_dialogs.dart';
import 'collection_providers.dart';

/// One collection: its entries in chronological order.
class CollectionScreen extends ConsumerWidget {
  const CollectionScreen({super.key, required this.collectionId});

  final int collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final collection = ref.watch(collectionProvider(collectionId));
    final entries = ref.watch(collectionEntriesProvider(collectionId));
    final c = collection.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(c?.name ?? ''),
        actions: [
          if (c != null)
            PopupMenuButton<String>(
              onSelected: (action) async {
                switch (action) {
                  case 'rename':
                    final name = await showCollectionNameDialog(
                      context,
                      initial: c.name,
                    );
                    if (name != null) {
                      await ref
                          .read(collectionRepositoryProvider)
                          .rename(c.id, name);
                    }
                  case 'delete':
                    if (await confirmDeleteCollection(context, ref, c) &&
                        context.mounted) {
                      Navigator.of(context).maybePop();
                    }
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'rename',
                  child: ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: Text(l10n.collectionRename),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: Text(l10n.collectionDelete),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: c == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => AddEntriesSheet.show(context, c.id),
              icon: const Icon(Icons.add),
              label: Text(l10n.collectionAddEntries),
            ),
      body: PaperBackground(
        child: entries.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(child: Text(l10n.errorGeneric)),
          data: (list) {
            if (list.isEmpty) {
              return EmptyState(
                icon: Icons.collections_bookmark_outlined,
                title: c?.name ?? '',
                body: l10n.collectionEmptyBody,
              );
            }
            final first = list.first.date;
            final last = list.last.date;
            return ListView(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 110),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                  child: Text(
                    [
                      l10n.collectionEntryCount(list.length),
                      _span(first, last),
                    ].join(' · '),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                for (final e in list)
                  JournalEntryCard(
                    entry: e,
                    collectionId: collectionId,
                    heroScope: 'collection:$collectionId',
                    onLongPress: () => _entryMenu(context, ref, e),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  static String _span(DateTime a, DateTime b) {
    final from = Fmt.mediumDate(a);
    final to = Fmt.mediumDate(b);
    return from == to ? from : '$from – $to';
  }

  Future<void> _entryMenu(
    BuildContext context,
    WidgetRef ref,
    NoteSummary entry,
  ) async {
    final l10n = AppLocalizations.of(context);
    final remove = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.remove_circle_outline),
          title: Text(l10n.collectionRemoveEntry),
          onTap: () => Navigator.pop(context, true),
        ),
      ),
    );
    if (remove == true) {
      await ref
          .read(collectionRepositoryProvider)
          .removeNote(collectionId, entry.id);
    }
  }
}

/// Picks several existing entries to add to a collection.
class AddEntriesSheet extends ConsumerStatefulWidget {
  const AddEntriesSheet({super.key, required this.collectionId});

  final int collectionId;

  static Future<void> show(BuildContext context, int collectionId) =>
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => FractionallySizedBox(
          heightFactor: 0.85,
          child: AddEntriesSheet(collectionId: collectionId),
        ),
      );

  @override
  ConsumerState<AddEntriesSheet> createState() => _AddEntriesSheetState();
}

class _AddEntriesSheetState extends ConsumerState<AddEntriesSheet> {
  final _selected = <int>{};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final all = ref.watch(allNotesProvider).value ?? const [];
    final inCollection = {
      for (final e
          in ref.watch(collectionEntriesProvider(widget.collectionId)).value ??
              const <NoteSummary>[])
        e.id,
    };
    final candidates = [
      for (final n in all)
        if (!inCollection.contains(n.id)) n,
    ];
    final cacheWidth = (56 * MediaQuery.devicePixelRatioOf(context)).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text(
            l10n.collectionAddEntries,
            style: theme.textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: candidates.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.collectionAddEntriesNone,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: candidates.length,
                  itemBuilder: (context, i) {
                    final n = candidates[i];
                    return CheckboxListTile(
                      value: _selected.contains(n.id),
                      onChanged: (v) => setState(
                        () => v == true
                            ? _selected.add(n.id)
                            : _selected.remove(n.id),
                      ),
                      secondary: SizedBox(
                        width: 44,
                        child: Polaroid(
                          tilt: Polaroid.tiltFor(n.assetId),
                          tape: false,
                          image: NotePhoto(
                            assetId: n.assetId,
                            thumbnailFile: n.thumbnailFile,
                            preferStoredCopy: true,
                            cacheWidth: cacheWidth,
                          ),
                        ),
                      ),
                      title: Text(
                        [Fmt.mediumDate(n.date), ?n.placeName].join(' · '),
                      ),
                      subtitle: Text(
                        n.preview.trim().split('\n').first,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: FilledButton(
              onPressed: _selected.isEmpty
                  ? null
                  : () {
                      unawaited(
                        ref
                            .read(collectionRepositoryProvider)
                            .addNotes(widget.collectionId, _selected),
                      );
                      Navigator.pop(context);
                    },
              child: Text(l10n.collectionAddSelected(_selected.length)),
            ),
          ),
        ),
      ],
    );
  }
}
