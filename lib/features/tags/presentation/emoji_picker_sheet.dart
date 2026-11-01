import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

/// Lets the user choose any emoji for a Stimmung: categories, a German
/// search and "recently used" (stored on the device only, by the
/// emoji_picker_flutter package). Only emojis the device can draw are
/// offered (glyph check on Android).
///
/// Returns the chosen emoji, or null if the sheet was dismissed.
Future<String?> showMoodEmojiPicker(
  BuildContext context, {
  String? selected,
}) async {
  var hasRecents = false;
  try {
    hasRecents = (await EmojiPickerUtils().getRecentEmojis()).isNotEmpty;
  } on Exception catch (e) {
    debugPrint('Emoji recents unavailable: $e');
  }
  if (!context.mounted) return null;
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) =>
        MoodEmojiPickerSheet(selected: selected, startWithRecents: hasRecents),
  );
}

class MoodEmojiPickerSheet extends StatelessWidget {
  const MoodEmojiPickerSheet({
    super.key,
    this.selected,
    this.startWithRecents = true,
  });

  final String? selected;
  final bool startWithRecents;

  /// Rows of the emoji grid; the sheet is about 60 % of a phone screen.
  static const double pickerHeight = 340;

  /// Themed configuration (shared with tests).
  static Config configFor(
    BuildContext context, {
    bool startWithRecents = true,
    bool checkPlatformCompatibility = true,
  }) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final background = scheme.surfaceContainerLow;
    return Config(
      height: pickerHeight,
      locale: const Locale('de'),
      checkPlatformCompatibility: checkPlatformCompatibility,
      emojiViewConfig: EmojiViewConfig(
        columns: 8,
        emojiSizeMax: 30,
        backgroundColor: background,
        gridPadding: const EdgeInsets.symmetric(horizontal: 8),
        recentsLimit: 32,
        noRecents: Text(
          l10n.emojiNoRecents,
          textAlign: TextAlign.center,
          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 15),
        ),
        loadingIndicator: const Center(
          child: SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      categoryViewConfig: CategoryViewConfig(
        initCategory: startWithRecents ? Category.RECENT : Category.SMILEYS,
        backgroundColor: background,
        indicatorColor: scheme.primary,
        iconColor: scheme.onSurfaceVariant.withValues(alpha: 0.7),
        iconColorSelected: scheme.primary,
        backspaceColor: scheme.primary,
        dividerColor: scheme.outlineVariant,
      ),
      skinToneConfig: SkinToneConfig(
        dialogBackgroundColor: scheme.surfaceContainerHighest,
        indicatorColor: scheme.outline,
      ),
      bottomActionBarConfig: BottomActionBarConfig(
        showBackspaceButton: false,
        backgroundColor: background,
        buttonColor: scheme.secondaryContainer,
        buttonIconColor: scheme.onSecondaryContainer,
      ),
      searchViewConfig: SearchViewConfig(
        backgroundColor: background,
        buttonIconColor: scheme.onSurfaceVariant,
        hintText: l10n.emojiSearchHint,
        inputTextStyle: TextStyle(color: scheme.onSurface, fontSize: 16),
        hintTextStyle: TextStyle(color: scheme.onSurfaceVariant),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      // The search field brings up the keyboard: stay above it.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.emojiPickerTitle,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                if (selected != null)
                  Semantics(
                    label: l10n.emojiCurrent,
                    child: Text(
                      selected!,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: EmojiPicker(
              config: configFor(context, startWithRecents: startWithRecents),
              onEmojiSelected: (_, emoji) =>
                  Navigator.of(context).pop(emoji.emoji),
            ),
          ),
        ],
      ),
    );
  }
}
