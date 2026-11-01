import 'package:flutter/foundation.dart';

import '../../library/domain/photo_repository.dart';
import '../../notes/domain/note.dart';
import '../domain/geo.dart';
import 'geo_database.dart';

/// One-time back-fill of country and place for notes written before
/// schema v7: from the photo's GPS data (read from the gallery, never
/// stored), or – for photos without GPS – from the place name typed in
/// earlier ("Wien" → Austria). A place a note already has is kept. Notes
/// for which something was found are marked and not looked at again; the
/// others stay waiting – a later run (e.g. after allowing access to photo
/// locations) tries them again. The automatic run happens only once.
class GeoBackfill {
  GeoBackfill({required this.notes, required this.photos, required this.geo});

  final NoteRepository notes;
  final PhotoRepository photos;
  final GeoDatabase geo;

  /// Processes the waiting notes, newest first. [onProgress] gets
  /// (done, total) after each note; returning true from [isCancelled]
  /// stops after the current note (the rest stays waiting).
  Future<({int done, int total})> run({
    void Function(int done, int total)? onProgress,
    bool Function()? isCancelled,
  }) async {
    final pending = await notes.notesNeedingGeo();
    final total = pending.length;
    var done = 0;
    onProgress?.call(done, total);
    for (final note in pending) {
      if (isCancelled?.call() ?? false) break;
      final match = await _lookup(note.assetId, note.placeName);
      if (!match.isEmpty) {
        await notes.setGeo(
          note.id,
          countryCode: match.countryCode,
          placeName: match.placeName,
          placeNameAlt: match.placeNameAlt,
        );
      }
      done++;
      onProgress?.call(done, total);
    }
    return (done: done, total: total);
  }

  Future<GeoMatch> _lookup(String assetId, String? placeName) async {
    try {
      final location = await photos.locationOf(assetId);
      if (location != null && location.isValid) return geo.resolve(location);
    } on Exception catch (e) {
      debugPrint('Back-fill: no location for $assetId: $e');
    }
    if (placeName != null) {
      final known = geo.lookupPlace(placeName);
      if (known != null) return known;
    }
    return const GeoMatch();
  }
}
