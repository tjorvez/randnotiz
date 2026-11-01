import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../l10n/generated/app_localizations.dart';

/// The photo plus in the navigation pill – the way to a new entry (it fills
/// the slot the pill gives it). Opens the system photo picker (which includes
/// Google Photos if it is set as cloud media app), imports the chosen photo
/// as a private copy and opens the editor for it.
class PickExternalPhotoButton extends ConsumerStatefulWidget {
  const PickExternalPhotoButton({super.key});

  @override
  ConsumerState<PickExternalPhotoButton> createState() =>
      _PickExternalPhotoButtonState();
}

class _PickExternalPhotoButtonState
    extends ConsumerState<PickExternalPhotoButton> {
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
      messenger.showSnackBar(SnackBar(content: Text(l10n.libraryImportFailed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final label = _busy
        ? l10n.libraryImporting
        : l10n.libraryPickExternalTooltip;
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
