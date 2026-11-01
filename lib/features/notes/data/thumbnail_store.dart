import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

/// Stores the downscaled JPEG copies (~800 px) of noted photos in the app's
/// private storage. They keep journal entries intact if the original photo is
/// deleted and are the image source for the widget and (later) the backup.
class ThumbnailStore {
  ThumbnailStore(this.directory);

  final Directory directory;

  static final _unsafe = RegExp(r'[^A-Za-z0-9_-]');

  /// Deterministic file name for an asset id.
  static String fileNameFor(String assetId) =>
      'note_${assetId.replaceAll(_unsafe, '_')}.jpg';

  File fileFor(String fileName) =>
      File(p.join(directory.path, p.basename(fileName)));

  Future<String> save(String assetId, Uint8List jpeg) async {
    await directory.create(recursive: true);
    final name = fileNameFor(assetId);
    final tmp = File(p.join(directory.path, '$name.tmp'));
    await tmp.writeAsBytes(jpeg, flush: true);
    await tmp.rename(fileFor(name).path); // atomic replace
    return name;
  }

  /// Writes a file under the given name (restoring a backup).
  Future<String> saveNamed(String fileName, Uint8List bytes) async {
    await directory.create(recursive: true);
    final name = p.basename(fileName);
    final tmp = File(p.join(directory.path, '$name.tmp'));
    await tmp.writeAsBytes(bytes, flush: true);
    await tmp.rename(fileFor(name).path);
    return name;
  }

  /// Deterministic file name for the cover of a Spotify track.
  static String coverFileNameFor(String trackId) =>
      'song_${trackId.replaceAll(_unsafe, '_')}.jpg';

  /// Stores the cover of a linked song (shared by all notes with that song).
  Future<String> saveCover(String trackId, Uint8List jpeg) async {
    await directory.create(recursive: true);
    final name = coverFileNameFor(trackId);
    final tmp = File(p.join(directory.path, '$name.tmp'));
    await tmp.writeAsBytes(jpeg, flush: true);
    await tmp.rename(fileFor(name).path);
    return name;
  }

  /// Removes covers no note uses any more ([inUse] = still used ones).
  /// Covers younger than [minAge] stay: one may just have been stored for a
  /// song whose note is about to be saved.
  Future<int> deleteUnusedCovers(
    Set<String> inUse, {
    Duration minAge = const Duration(minutes: 10),
    DateTime? now,
  }) async {
    final cutoff = (now ?? DateTime.now()).subtract(minAge);
    if (!await directory.exists()) return 0;
    var removed = 0;
    await for (final entity in directory.list()) {
      final name = p.basename(entity.path);
      if (entity is File &&
          name.startsWith('song_') &&
          name.endsWith('.jpg') &&
          !inUse.contains(name) &&
          (await entity.lastModified()).isBefore(cutoff)) {
        await entity.delete();
        removed++;
      }
    }
    return removed;
  }

  Future<bool> exists(String? fileName) async =>
      fileName != null && await fileFor(fileName).exists();

  Future<void> delete(String? fileName) async {
    if (fileName == null) return;
    final file = fileFor(fileName);
    if (await file.exists()) await file.delete();
  }
}
