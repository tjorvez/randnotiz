import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../library/domain/photo_repository.dart';
import '../data/thumbnail_store.dart';

/// Shows a note's photo: the original from the gallery if available,
/// otherwise the stored ~800 px copy.
class NotePhoto extends ConsumerWidget {
  const NotePhoto({
    super.key,
    required this.assetId,
    this.thumbnailFile,
    this.photo,
    this.cacheWidth,
    this.preferStoredCopy = false,
  });

  final String assetId;
  final String? thumbnailFile;

  /// If known, the gallery photo (used for full-size display in the editor).
  final PhotoItem? photo;
  final int? cacheWidth;

  /// Lists use the small stored copy: fast and independent of the gallery.
  final bool preferStoredCopy;

  /// The image a [NotePhoto] with `preferStoredCopy` shows for a stored
  /// copy – the same image cache entry, e.g. to decode it ahead of time.
  static ImageProvider storedCopyProvider(
    ThumbnailStore store,
    String fileName, {
    int? cacheWidth,
  }) {
    final file = FileImage(store.fileFor(fileName));
    return cacheWidth == null
        ? file
        : ResizeImage(file, width: cacheWidth, policy: ResizeImagePolicy.fit);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final placeholder = ColoredBox(
      color: scheme.surfaceContainerHigh,
      child: Center(child: Icon(Icons.image_outlined, color: scheme.outline)),
    );

    ImageProvider? provider;
    final stored = thumbnailFile == null
        ? null
        : ref.watch(thumbnailStoreProvider).fileFor(thumbnailFile!);
    final photos = ref.watch(photoRepositoryProvider);
    if (photo != null && !preferStoredCopy) {
      // Editor: the small copy appears at once, the full photo fades in
      // over it as soon as it is decoded.
      final preview = stored != null
          ? FileImage(stored) as ImageProvider
          : photos.imageFor(photo!, size: 400);
      return Stack(
        fit: StackFit.expand,
        children: [
          Image(
            image: preview,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => placeholder,
          ),
          Image(
            image: photos.imageFor(photo!),
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
            frameBuilder: (context, child, frame, sync) => sync
                ? child
                : AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: child,
                  ),
          ),
        ],
      );
    } else if (stored != null) {
      provider = FileImage(stored);
    } else if (photo != null) {
      provider = photos.imageFor(photo!, size: 400);
    } else {
      provider = photos.imageFor(
        PhotoItem(id: assetId, createdAt: DateTime(0), width: 400, height: 400),
        size: 400,
      );
    }
    if (cacheWidth != null && provider is FileImage) {
      provider = ResizeImage(
        provider,
        width: cacheWidth,
        policy: ResizeImagePolicy.fit,
      );
    }

    return Image(
      image: provider,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) {
        // Original gone and no copy: show a calm placeholder.
        if (stored != null && provider is! FileImage) {
          return Image.file(
            stored,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => placeholder,
          );
        }
        return placeholder;
      },
    );
  }
}

/// Hero tag of a note's polaroid. [scope] names the place it is shown in
/// (journal, memories, a collection, …): the same note may appear in several
/// places at once, and only the one that was tapped may fly into the note
/// page. The note page gets the tag through the route (see `openNote`).
@immutable
class NoteHeroTag {
  const NoteHeroTag(this.scope, this.assetId);

  final String scope;
  final String assetId;

  @override
  bool operator ==(Object other) =>
      other is NoteHeroTag && other.scope == scope && other.assetId == assetId;

  @override
  int get hashCode => Object.hash(scope, assetId);

  @override
  String toString() => 'NoteHeroTag($scope, $assetId)';
}
