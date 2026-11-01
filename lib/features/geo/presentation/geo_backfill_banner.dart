import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import 'geo_backfill_controller.dart';

/// Shown in the journal while countries and places of older notes are
/// being filled in: progress and a cancel button. Nothing otherwise.
class GeoBackfillBanner extends ConsumerWidget {
  const GeoBackfillBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(geoBackfillProvider);
    return AnimatedSize(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 220),
      child: !state.running
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
              child: Material(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 4, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.travel_explore,
                            size: 18,
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Semantics(
                              liveRegion: true,
                              child: Text(
                                l10n.geoBackfillProgress(
                                  state.done,
                                  state.total,
                                ),
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: ref
                                .read(geoBackfillProvider.notifier)
                                .cancel,
                            child: Text(l10n.cancel),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: LinearProgressIndicator(
                          value: state.total == 0 ? null : state.progress,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
