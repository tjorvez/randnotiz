import 'package:flutter/foundation.dart';

import '../../notes/domain/note.dart';

/// A collection ("Sammlung") of diary entries, e.g. a trip or a person.
@immutable
class Collection {
  const Collection({
    required this.id,
    required this.name,
    required this.createdAt,
    this.noteCount = 0,
    this.covers = const [],
  });

  final int id;
  final String name;
  final DateTime createdAt;
  final int noteCount;

  /// Up to three entries (newest first) for the cover.
  final List<CollectionCover> covers;

  @override
  bool operator ==(Object other) =>
      other is Collection &&
      other.id == id &&
      other.name == name &&
      other.noteCount == noteCount &&
      listEquals(other.covers, covers);

  @override
  int get hashCode => Object.hash(id, name, noteCount, Object.hashAll(covers));
}

@immutable
class CollectionCover {
  const CollectionCover({
    required this.noteId,
    required this.assetId,
    this.thumbnailFile,
  });

  final int noteId;
  final String assetId;
  final String? thumbnailFile;

  @override
  bool operator ==(Object other) =>
      other is CollectionCover &&
      other.noteId == noteId &&
      other.thumbnailFile == thumbnailFile;

  @override
  int get hashCode => Object.hash(noteId, thumbnailFile);
}

/// The entries around [current] in a chronologically ordered collection.
@immutable
class CollectionNeighbours {
  const CollectionNeighbours({
    required this.position,
    required this.total,
    this.previous,
    this.next,
  });

  /// 1-based position of the current entry.
  final int position;
  final int total;
  final NoteSummary? previous;
  final NoteSummary? next;

  /// Null if [noteId] is not part of [entries].
  static CollectionNeighbours? of(List<NoteSummary> entries, int noteId) {
    final i = entries.indexWhere((e) => e.id == noteId);
    if (i < 0) return null;
    return CollectionNeighbours(
      position: i + 1,
      total: entries.length,
      previous: i > 0 ? entries[i - 1] : null,
      next: i < entries.length - 1 ? entries[i + 1] : null,
    );
  }
}

abstract interface class CollectionRepository {
  /// All collections in the user's order (new ones first), with counts and
  /// covers.
  Stream<List<Collection>> watchCollections();

  Stream<Collection?> watchCollection(int id);

  /// Ids of the collections that contain [noteId].
  Stream<Set<int>> watchCollectionIdsOf(int noteId);

  Future<Collection> create(String name);

  Future<void> rename(int id, String name);

  /// Deletes the collection; its notes stay untouched.
  Future<void> delete(int id);

  Future<void> addNotes(int collectionId, Iterable<int> noteIds);

  Future<void> removeNote(int collectionId, int noteId);

  /// Stores the order of the overview: [orderedIds] from first to last.
  Future<void> reorder(List<int> orderedIds);
}
