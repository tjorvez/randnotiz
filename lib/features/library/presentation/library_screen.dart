import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/home_shell.dart';
import '../../../app/providers.dart';
import '../../../core/format/formatters.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/polaroid.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../notes/presentation/note_photo.dart';
import '../../notes/presentation/open_note.dart';
import '../domain/library_rows.dart';
import '../domain/photo_repository.dart';
import 'library_controller.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The user may have changed the permission in the system settings.
    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(libraryProvider.notifier).refreshAccess());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(libraryProvider);
    final controller = ref.read(libraryProvider.notifier);

    final content = switch (state.access) {
      null => const Center(child: CircularProgressIndicator()),
      PhotoAccess.denied => EmptyState(
        icon: Icons.photo_library_outlined,
        title: l10n.libraryPermissionTitle,
        // The "denied" hint only appears after the user actually declined.
        body: state.askedOnce
            ? '${l10n.libraryPermissionBody}\n\n${l10n.libraryPermissionDeniedBody}'
            : l10n.libraryPermissionBody,
        action: Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            FilledButton(
              onPressed: controller.requestAccess,
              child: Text(l10n.libraryPermissionButton),
            ),
            if (state.askedOnce)
              TextButton(
                onPressed: controller.manageAccess,
                child: Text(l10n.openSystemSettings),
              ),
          ],
        ),
      ),
      _ => Column(
        children: [
          if (state.access == PhotoAccess.limited)
            _LimitedBanner(controller: controller),
          Expanded(child: _PhotoGrid(state: state)),
        ],
      ),
    };
    return content;
  }
}

class _LimitedBanner extends StatelessWidget {
  const _LimitedBanner({required this.controller});

  final LibraryController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: scheme.onSecondaryContainer,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.libraryLimitedBanner,
                    style: TextStyle(color: scheme.onSecondaryContainer),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                children: [
                  TextButton(
                    onPressed: controller.manageAccess,
                    child: Text(l10n.libraryLimitedPickMore),
                  ),
                  TextButton(
                    onPressed: controller.requestAccess,
                    child: Text(l10n.libraryLimitedAllowAll),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The grid rows of the last build: re-grouping every loaded photo into
/// months and rows on each rebuild (e.g. whenever a note is saved) is
/// wasted work while the photos and the column count stay the same.
final _rowsMemo = _LibraryRowsMemo();

class _LibraryRowsMemo {
  List<PhotoItem>? _photos;
  int? _columns;
  List<LibraryRow> _rows = const [];

  List<LibraryRow> rowsFor(List<PhotoItem> photos, int columns) {
    if (!identical(photos, _photos) || columns != _columns) {
      _rows = buildLibraryRows(photos, columns: columns);
      _photos = photos;
      _columns = columns;
    }
    return _rows;
  }
}

class _PhotoGrid extends ConsumerWidget {
  const _PhotoGrid({required this.state});

  final LibraryState state;

  static const _spacing = 3.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (state.photos.isEmpty && !state.loading && !state.hasMore) {
      return EmptyState(
        icon: Icons.photo_outlined,
        title: l10n.navLibrary,
        body: l10n.libraryEmpty,
      );
    }
    final noted = ref.watch(notedAssetIdsProvider).value ?? const <String>{};
    final repo = ref.watch(photoRepositoryProvider);
    final controller = ref.read(libraryProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / 110).floor().clamp(3, 8);
        final rows = _rowsMemo.rowsFor(state.photos, columns);
        final cell =
            (constraints.maxWidth - 24 - _spacing * (columns - 1)) / columns;
        final thumbPx = (cell * MediaQuery.devicePixelRatioOf(context))
            .round()
            .clamp(128, 400);

        return NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.metrics.extentAfter < 1500) unawaited(controller.loadMore());
            return false;
          },
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, floatingNavClearance),
            itemCount: rows.length + (state.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= rows.length) {
                // Never modify providers during build: load after this frame.
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => unawaited(controller.loadMore()),
                );
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return switch (rows[index]) {
                MonthHeaderRow(:final month) => Padding(
                  padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
                  child: Text(
                    Fmt.month(month),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                PhotoGridRow(:final photos) => Padding(
                  padding: const EdgeInsets.only(bottom: _spacing),
                  child: Row(
                    children: [
                      for (var i = 0; i < columns; i++) ...[
                        if (i > 0) const SizedBox(width: _spacing),
                        SizedBox.square(
                          dimension: cell,
                          child: i < photos.length
                              ? _PhotoTile(
                                  photo: photos[i],
                                  image: repo.imageFor(
                                    photos[i],
                                    size: thumbPx,
                                  ),
                                  hasNote: noted.contains(photos[i].id),
                                )
                              : null,
                        ),
                      ],
                    ],
                  ),
                ),
              };
            },
          ),
        );
      },
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.photo,
    required this.image,
    required this.hasNote,
  });

  final PhotoItem photo;
  final ImageProvider image;
  final bool hasNote;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: [
        l10n.libraryPhotoOf(Fmt.longDate(photo.createdAt)),
        if (hasNote) l10n.libraryHasNote,
      ].join(', '),
      child: GestureDetector(
        onTap: () => openNote(
          context,
          photo.id,
          heroTag: NoteHeroTag('library', photo.id),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: scheme.surfaceContainerHigh),
              FramelessPolaroidHero(
                tag: NoteHeroTag('library', photo.id),
                image: Image(
                  image: image,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  errorBuilder: (_, _, _) =>
                      Icon(Icons.broken_image_outlined, color: scheme.outline),
                  frameBuilder: (context, child, frame, sync) => sync
                      ? child
                      : AnimatedOpacity(
                          opacity: frame == null ? 0 : 1,
                          duration: const Duration(milliseconds: 180),
                          child: child,
                        ),
                ),
              ),
              if (hasNote)
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    // A light rim instead of a blurred shadow: cheap to
                    // paint while flinging through hundreds of tiles.
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: scheme.surface.withValues(alpha: 0.85),
                        width: 1.2,
                      ),
                    ),
                    child: Icon(Icons.edit, size: 13, color: scheme.onPrimary),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
