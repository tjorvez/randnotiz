import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/collection.dart';

/// Asks for a collection name. Returns null if cancelled.
Future<String?> showCollectionNameDialog(
  BuildContext context, {
  String? initial,
}) => showDialog<String>(
  context: context,
  builder: (_) => _CollectionNameDialog(initial: initial),
);

/// Owns its text controller, so it lives exactly as long as the dialog
/// (including its closing animation).
class _CollectionNameDialog extends StatefulWidget {
  const _CollectionNameDialog({this.initial});

  final String? initial;

  @override
  State<_CollectionNameDialog> createState() => _CollectionNameDialogState();
}

class _CollectionNameDialogState extends State<_CollectionNameDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isNotEmpty) Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isNew = widget.initial == null;
    return AlertDialog(
      title: Text(isNew ? l10n.collectionNew : l10n.collectionRename),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 60,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: l10n.collectionNameLabel,
          hintText: l10n.collectionNameHint,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isNew ? l10n.create : l10n.save),
        ),
      ],
    );
  }
}

/// Creates a collection after asking for its name.
Future<Collection?> createCollection(
  BuildContext context,
  WidgetRef ref,
) async {
  final name = await showCollectionNameDialog(context);
  if (name == null) return null;
  return ref.read(collectionRepositoryProvider).create(name);
}

/// Confirms and deletes a collection. Returns true if deleted.
Future<bool> confirmDeleteCollection(
  BuildContext context,
  WidgetRef ref,
  Collection collection,
) async {
  final l10n = AppLocalizations.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.collectionDeleteConfirmTitle),
      content: Text(l10n.collectionDeleteConfirmBody(collection.name)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.delete),
        ),
      ],
    ),
  );
  if (ok != true) return false;
  await ref.read(collectionRepositoryProvider).delete(collection.id);
  return true;
}
