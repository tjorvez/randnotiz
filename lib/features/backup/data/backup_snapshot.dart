import 'dart:convert';

import 'package:crypto/crypto.dart' as hash;
import 'package:drift/drift.dart' show OrderingTerm;

import '../../../core/database/app_database.dart';

/// Kind of a file stored next to the snapshot.
enum BackupFileKind {
  /// A file of the thumbnail directory: ~800 px copy of a note's photo or
  /// the cover of a song (`ThumbnailStore`).
  thumbnail,

  /// The private copy (≤ 1600 px) of a photo picked from outside the
  /// gallery, keyed by the note's `picked:` asset id (`ImportedPhotoStore`).
  imported,
}

/// One photo or cover of the backup. [blob] names the encrypted object on
/// the server; it is derived from [sha256], so equal content is stored once.
class BackupFile {
  const BackupFile({
    required this.kind,
    required this.name,
    required this.sha256,
    required this.size,
    required this.blob,
  });

  final BackupFileKind kind;

  /// File name in the thumbnail directory, or the asset id for [imported].
  final String name;
  final String sha256;
  final int size;
  final String blob;

  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'name': name,
    'sha256': sha256,
    'size': size,
    'blob': blob,
  };

  static BackupFile fromJson(Map<String, Object?> json) => BackupFile(
    kind: BackupFileKind.values.byName(json['kind']! as String),
    name: json['name']! as String,
    sha256: json['sha256']! as String,
    size: json['size']! as int,
    blob: json['blob']! as String,
  );
}

/// Capture date and size of a note's photo at backup time. Lets a restore
/// tell whether a gallery id on this device still means the same photo
/// (MediaStore ids are per device; another phone may use the same number
/// for a different picture).
typedef BackupPhotoInfo = ({DateTime takenAt, int width, int height});

/// Versioned JSON export of the diary – the payload of a backup (encrypted
/// before upload, see `BackupWriter`). Independent of the SQLite schema so
/// that backups survive schema migrations.
///
/// * v1 (prepared, never uploaded): notes and tags.
/// * v2: plus uids, collections with their notes, the geo flag, photo
///   info and the list of files ([files]).
class BackupSnapshot {
  const BackupSnapshot({
    required this.createdAt,
    required this.notes,
    required this.tags,
    this.collections = const [],
    this.files = const [],
    this.version = formatVersion,
  });

  static const formatVersion = 2;

  final DateTime createdAt;
  final List<Map<String, Object?>> notes;
  final List<Map<String, Object?>> tags;
  final List<Map<String, Object?>> collections;
  final List<BackupFile> files;

  /// Format version this snapshot was read from.
  final int version;

  /// Reads all notes, tags and collections. [photoInfo] supplies capture
  /// date and size of gallery photos (null where unknown).
  static Future<BackupSnapshot> fromDatabase(
    AppDatabase db, {
    DateTime? now,
    Future<BackupPhotoInfo?> Function(String assetId)? photoInfo,
  }) async {
    final tagRows = await (db.select(
      db.tags,
    )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
    final links = await db.select(db.noteTags).get();
    final noteRows = await (db.select(
      db.notes,
    )..orderBy([(n) => OrderingTerm.asc(n.id)])).get();
    final collectionRows = await (db.select(
      db.collections,
    )..orderBy([(c) => OrderingTerm.asc(c.position)])).get();
    final members = await (db.select(
      db.collectionNotes,
    )..orderBy([(m) => OrderingTerm.asc(m.addedAt)])).get();

    final tagsByNote = <int, List<int>>{};
    for (final l in links) {
      tagsByNote.putIfAbsent(l.noteId, () => []).add(l.tagId);
    }
    final uidById = {for (final n in noteRows) n.id: n.uid};
    final membersByCollection = <int, List<CollectionNoteRow>>{};
    for (final m in members) {
      membersByCollection.putIfAbsent(m.collectionId, () => []).add(m);
    }

    final notes = <Map<String, Object?>>[];
    for (final n in noteRows) {
      final info = photoInfo == null ? null : await photoInfo(n.assetId);
      notes.add({
        'uid': n.uid,
        'assetId': n.assetId,
        'body': n.body,
        'title': n.title,
        'photoAspect': n.photoAspect,
        'date': n.noteDate.toUtc().toIso8601String(),
        'weatherKind': n.weatherKind,
        'temperatureC': n.temperatureC,
        'placeName': n.placeName,
        'placeNameAlt': n.placeNameAlt,
        'countryCode': n.countryCode,
        'geoChecked': n.geoChecked,
        'thumbnailFile': n.thumbnailFile,
        'songUri': n.songUri,
        'songTitle': n.songTitle,
        'songArtist': n.songArtist,
        'songCoverFile': n.songCoverFile,
        'tagIds': tagsByNote[n.id] ?? const <int>[],
        if (info != null)
          'photo': {
            'takenAt': info.takenAt.toUtc().toIso8601String(),
            'width': info.width,
            'height': info.height,
          },
        'createdAt': n.createdAt.toUtc().toIso8601String(),
        'updatedAt': n.updatedAt.toUtc().toIso8601String(),
      });
    }

    return BackupSnapshot(
      createdAt: now ?? DateTime.now(),
      tags: [
        for (final t in tagRows) {'id': t.id, 'name': t.name, 'emoji': t.emoji},
      ],
      notes: notes,
      collections: [
        for (final c in collectionRows)
          {
            'uid': c.uid,
            'name': c.name,
            'createdAt': c.createdAt.toUtc().toIso8601String(),
            'position': c.position,
            'notes': [
              for (final m in membersByCollection[c.id] ?? const [])
                if (uidById[m.noteId] case final uid?)
                  {'uid': uid, 'addedAt': m.addedAt.toUtc().toIso8601String()},
            ],
          },
      ],
    );
  }

  BackupSnapshot withFiles(List<BackupFile> files) => BackupSnapshot(
    createdAt: createdAt,
    notes: notes,
    tags: tags,
    collections: collections,
    files: files,
    version: version,
  );

  Map<String, Object?> _content() => {
    'tags': tags,
    'notes': notes,
    'collections': collections,
    'files': [for (final f in files) f.toJson()],
  };

  /// SHA-256 of everything but the creation time: equal hashes mean nothing
  /// changed since the last backup.
  String get contentHash =>
      hash.sha256.convert(utf8.encode(jsonEncode(_content()))).toString();

  String encode() => jsonEncode({
    'format': 'randnotiz-backup',
    'version': formatVersion,
    'createdAt': createdAt.toUtc().toIso8601String(),
    ..._content(),
  });

  static BackupSnapshot decode(String source) {
    final json = jsonDecode(source);
    if (json is! Map<String, Object?> || json['format'] != 'randnotiz-backup') {
      throw const FormatException('Not a Randnotiz backup');
    }
    final version = json['version'];
    if (version is! int || version > formatVersion) {
      throw FormatException('Unsupported backup version $version');
    }
    List<Map<String, Object?>> list(Object? v) =>
        (v as List? ?? const []).cast<Map<String, Object?>>();
    return BackupSnapshot(
      createdAt: DateTime.parse(json['createdAt']! as String),
      tags: list(json['tags']),
      notes: list(json['notes']),
      collections: list(json['collections']),
      files: [for (final f in list(json['files'])) BackupFile.fromJson(f)],
      version: version,
    );
  }
}
