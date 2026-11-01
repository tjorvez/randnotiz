import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../notes/presentation/note_editor_controller.dart';
import 'tag_dialogs.dart';

/// Select tags for a note and create new ones on the fly.
class TagPickerSheet extends ConsumerWidget {
  const TagPickerSheet({super.key, required this.assetId});

  final String assetId;

  static Future<void> show(BuildContext context, String assetId) =>
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => TagPickerSheet(assetId: assetId),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tags = ref.watch(tagsProvider).value ?? const [];
    final selected = ref.watch(
      noteEditorProvider(assetId).select((s) => s.tagIds),
    );
    final controller = ref.read(noteEditorProvider(assetId).notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.tagsSheetTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (tags.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(l10n.tagsNone),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in tags)
                FilterChip(
                  avatar: Text(tag.emoji),
                  label: Text(tag.name),
                  selected: selected.contains(tag.id),
                  onSelected: (_) => controller.toggleTag(tag.id),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: Text(l10n.tagsCreateNew),
                onPressed: () async {
                  final tag = await showTagEditDialog(context);
                  if (tag != null) controller.addTag(tag.id);
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
