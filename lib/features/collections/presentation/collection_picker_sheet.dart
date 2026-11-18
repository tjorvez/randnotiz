import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'collection_dialogs.dart';
import 'collection_providers.dart';

/// Puts a note into collections (or takes it out) and creates new ones.
class CollectionPickerSheet extends ConsumerWidget {
  const CollectionPickerSheet({super.key, required this.noteId});

  final int noteId;

  static Future<void> show(BuildContext context, int noteId) =>
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => CollectionPickerSheet(noteId: noteId),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final collections = ref.watch(collectionsProvider).value ?? const [];
    final selected =
        ref.watch(noteCollectionIdsProvider(noteId)).value ?? const {};
    final repo = ref.read(collectionRepositoryProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.collectionPickerTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            l10n.collectionPickerHint,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          for (final c in collections)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: selected.contains(c.id),
              title: Text(c.name),
              subtitle: Text(l10n.collectionEntryCount(c.noteCount)),
              onChanged: (v) => unawaited(
                v == true
                    ? repo.addNotes(c.id, [noteId])
                    : repo.removeNote(c.id, noteId),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: Text(l10n.collectionNew),
                onPressed: () async {
                  final created = await createCollection(context, ref);
                  if (created != null) {
                    await repo.addNotes(created.id, [noteId]);
                  }
                },
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.done),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
