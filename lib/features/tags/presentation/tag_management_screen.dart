import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/widgets/common.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/tag.dart';
import 'tag_dialogs.dart';

final tagUsageProvider = StreamProvider.autoDispose<Map<int, int>>(
  (ref) => ref.watch(tagRepositoryProvider).watchUsageCounts(),
);

class TagManagementScreen extends ConsumerWidget {
  const TagManagementScreen({super.key});

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Tag tag,
    int usage,
  ) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.tagDeleteConfirmTitle(tag.name)),
        content: Text(l10n.tagDeleteConfirmBody(usage)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok == true) await ref.read(tagRepositoryProvider).deleteTag(tag.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tags = ref.watch(tagsProvider).value ?? const [];
    final usage = ref.watch(tagUsageProvider).value ?? const {};

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tagManageTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showTagEditDialog(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.tagsCreateNew),
      ),
      body: tags.isEmpty
          ? EmptyState(
              icon: Icons.sell_outlined,
              title: l10n.tagManageTitle,
              body: l10n.tagsNone,
            )
          : ListView.separated(
              padding: const EdgeInsets.only(bottom: 96),
              itemCount: tags.length,
              separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
              itemBuilder: (context, i) {
                final tag = tags[i];
                final count = usage[tag.id] ?? 0;
                return ListTile(
                  leading: Text(
                    tag.emoji,
                    style: const TextStyle(fontSize: 26),
                  ),
                  title: Text(tag.name),
                  subtitle: Text(l10n.tagUsage(count)),
                  onTap: () => showTagEditDialog(context, existing: tag),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: l10n.tagEdit,
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () =>
                            showTagEditDialog(context, existing: tag),
                      ),
                      IconButton(
                        tooltip: l10n.delete,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () =>
                            unawaited(_delete(context, ref, tag, count)),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
