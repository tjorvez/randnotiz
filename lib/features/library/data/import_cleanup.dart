import 'package:flutter/foundation.dart';

import '../../notes/data/thumbnail_store.dart';
import '../../notes/domain/note.dart';
import 'imported_photo_store.dart';

/// The start-up clean-up: removes copies of picked photos that never got a
/// note, and covers of songs no note links any more.
///
/// Never while [paused] says so – after lost notes (lostNotesProvider) the
/// database is empty, and every copy belongs to a note that is merely
/// missing until the backup is restored.
class ImportCleanup {
  ImportCleanup({
    required this.notes,
    required this.imports,
    required this.thumbnails,
    required this.paused,
  });

  final NoteRepository notes;
  final ImportedPhotoStore imports;
  final ThumbnailStore thumbnails;
  final bool Function() paused;

  Future<void> run() async {
    if (paused()) return;
    final noted = await notes.watchNotedAssetIds().first;
    await imports.deleteOrphans(noted);
    try {
      await thumbnails.deleteUnusedCovers(await notes.songCoverFilesInUse());
    } on Exception catch (e) {
      debugPrint('Cover clean-up failed: $e');
    }
  }
}
