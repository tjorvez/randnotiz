import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/mood_emoji_suggestions.dart';
import '../domain/tag.dart';
import 'emoji_picker_sheet.dart';

/// Dialog to create a Stimmung (or edit one if [existing] is given).
/// Returns the created/edited tag, or null if cancelled.
Future<Tag?> showTagEditDialog(BuildContext context, {Tag? existing}) =>
    showDialog<Tag>(
      context: context,
      builder: (_) => _TagEditDialog(existing: existing),
    );

class _TagEditDialog extends ConsumerStatefulWidget {
  const _TagEditDialog({this.existing});

  final Tag? existing;

  @override
  ConsumerState<_TagEditDialog> createState() => _TagEditDialogState();
}

class _TagEditDialogState extends ConsumerState<_TagEditDialog> {
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late String _emoji = widget.existing?.emoji ?? defaultMoodEmoji;

  /// Until the user picks an emoji, a new Stimmung follows its name.
  late bool _emojiChosen = widget.existing != null;
  String? _error;
  bool _busy = false;

  void _onNameChanged(String name) {
    if (_error != null) setState(() => _error = null);
    if (_emojiChosen) return;
    final suggestion = suggestMoodEmoji(name) ?? defaultMoodEmoji;
    if (suggestion != _emoji) setState(() => _emoji = suggestion);
  }

  Future<void> _pickEmoji() async {
    final picked = await showMoodEmojiPicker(context, selected: _emoji);
    if (picked == null || !mounted) return;
    setState(() {
      _emoji = picked;
      _emojiChosen = true;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = l10n.tagNameEmpty);
      return;
    }
    setState(() => _busy = true);
    final repo = ref.read(tagRepositoryProvider);
    try {
      final existing = widget.existing;
      final Tag tag;
      if (existing == null) {
        tag = await repo.createTag(name, emoji: _emoji);
      } else {
        if (name != existing.name) await repo.renameTag(existing.id, name);
        if (_emoji != existing.emoji) await repo.setEmoji(existing.id, _emoji);
        tag = Tag(id: existing.id, name: name, emoji: _emoji);
      }
      if (mounted) Navigator.pop(context, tag);
    } on DuplicateTagNameException {
      setState(() {
        _error = l10n.tagDuplicate;
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.existing == null ? l10n.tagsCreateNew : l10n.tagEdit),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EmojiButton(emoji: _emoji, onTap: _pickEmoji),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _name,
                    autofocus: widget.existing == null,
                    maxLength: 40,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: _onNameChanged,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: l10n.tagNameLabel,
                      hintText: l10n.tagNameHint,
                      errorText: _error,
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: _pickEmoji,
                icon: const Icon(Icons.emoji_emotions_outlined),
                label: Text(l10n.emojiChange),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: Text(widget.existing == null ? l10n.create : l10n.save),
        ),
      ],
    );
  }
}

/// The Stimmung's emoji, large; tapping opens the full emoji picker.
class _EmojiButton extends StatelessWidget {
  const _EmojiButton({required this.emoji, required this.onTap});

  final String emoji;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: l10n.emojiChange,
      value: emoji,
      excludeSemantics: true,
      child: Material(
        color: scheme.surfaceContainerHigh,
        shape: CircleBorder(side: BorderSide(color: scheme.outlineVariant)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox.square(
            dimension: 56,
            child: Center(
              child: AnimatedSwitcher(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 160),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Text(
                  emoji,
                  key: ValueKey(emoji),
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
