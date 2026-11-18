import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

import '../../library/domain/photo_repository.dart';
import '../domain/note.dart';
import 'thumbnail_store.dart';

/// Fills in [Note.photoAspect] for notes from before schema v6, once: from
/// the gallery photo if it is still there, otherwise from the stored copy.
/// Notes without either stay square.
class PhotoAspectBackfill {
  PhotoAspectBackfill({
    required this.notes,
    required this.photos,
    required this.thumbnails,
    this.readFileAspect = imageAspectOfFile,
  });

  final NoteRepository notes;
  final PhotoRepository photos;
  final ThumbnailStore thumbnails;
  final Future<double?> Function(File file) readFileAspect;

  /// Returns the number of notes updated.
  Future<int> run() async {
    var updated = 0;
    for (final n in await notes.notesWithoutPhotoAspect()) {
      double? aspect;
      try {
        aspect = (await photos.findById(n.assetId))?.aspectRatio;
      } on Exception catch (e) {
        debugPrint('Aspect: gallery lookup failed: $e');
      }
      final file = n.thumbnailFile;
      if (aspect == null && file != null && await thumbnails.exists(file)) {
        aspect = await readFileAspect(thumbnails.fileFor(file));
      }
      if (aspect != null && aspect.isFinite && aspect > 0) {
        await notes.setPhotoAspect(n.id, aspect);
        updated++;
      }
    }
    return updated;
  }
}

/// Width / height of an encoded image file, read from its header (the image
/// is not decoded).
Future<double?> imageAspectOfFile(File file) async {
  try {
    final buffer = await ui.ImmutableBuffer.fromFilePath(file.path);
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    final aspect = descriptor.height == 0
        ? null
        : descriptor.width / descriptor.height;
    descriptor.dispose();
    buffer.dispose();
    return aspect;
  } on Exception catch (e) {
    debugPrint('Aspect: cannot read ${file.path}: $e');
    return null;
  }
}
