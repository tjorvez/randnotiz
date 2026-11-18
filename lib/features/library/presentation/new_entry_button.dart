import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../l10n/generated/app_localizations.dart';

/// "Neuer Eintrag": an icon button for the navigation pill (it fills the
/// slot the pill gives it). Opens the system photo picker (device photos, and
/// Google Photos if it is set as cloud media app), imports the chosen photo as
/// a private copy and opens the editor for it. The only way to start a note –
/// the app has no gallery permission.
class NewEntryButton extends ConsumerStatefulWidget {
  const NewEntryButton({super.key});

  @override
  ConsumerState<NewEntryButton> createState() => _NewEntryButtonState();
}

class _NewEntryButtonState extends ConsumerState<NewEntryButton> {
  bool _busy = false;

  Future<void> _pick() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    setState(() => _busy = true);
    try {
      final item = await ref
          .read(importedPhotoStoreProvider)
          .pickAndImport(ref.read(externalPhotoPickerProvider));
      if (item == null) return; // cancelled
      unawaited(router.push('/note/${Uri.encodeComponent(item.id)}'));
    } on Exception catch (e) {
      debugPrint('Import failed: $e');
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.newEntryImportFailed)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final label = _busy ? l10n.newEntryImporting : l10n.newEntryTooltip;
    return Semantics(
      button: true,
      enabled: !_busy,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: _busy ? null : _pick,
          child: Center(
            child: _busy
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 22,
                    color: scheme.primary,
                  ),
          ),
        ),
      ),
    );
  }
}
