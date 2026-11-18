import 'package:drift/drift.dart';

import '../../../core/async/distinct_collections.dart';
import '../../../core/database/app_database.dart';
import '../domain/tag.dart';

class DriftTagRepository implements TagRepository {
  DriftTagRepository(this._db);

  final AppDatabase _db;

  static String normalizeName(String name) =>
      name.trim().replaceAll(RegExp(r'\s+'), ' ');

  @override
  Stream<List<Tag>> watchTags() {
    final query = _db.select(_db.tags)
      ..orderBy([(t) => OrderingTerm.asc(t.name.collate(Collate.noCase))]);
    return query
        .watch()
        .map(
          (rows) => rows
              .map((r) => Tag(id: r.id, name: r.name, emoji: r.emoji))
              .toList(),
        )
        .distinctLists();
  }

  @override
  Future<Tag> createTag(String name, {required String emoji}) {
    final clean = normalizeName(name);
    return _db.transaction(() async {
      await _ensureUnique(clean);
      final id = await _db
          .into(_db.tags)
          .insert(TagsCompanion.insert(name: clean, emoji: Value(emoji)));
      return Tag(id: id, name: clean, emoji: emoji);
    });
  }

  @override
  Future<void> renameTag(int id, String name) {
    final clean = normalizeName(name);
    return _db.transaction(() async {
      await _ensureUnique(clean, exceptId: id);
      await (_db.update(_db.tags)..where((t) => t.id.equals(id))).write(
        TagsCompanion(name: Value(clean)),
      );
      await _db.searchIndex.reindexNotesWithTag(id);
    });
  }

  @override
  Future<void> setEmoji(int id, String emoji) => (_db.update(
    _db.tags,
  )..where((t) => t.id.equals(id))).write(TagsCompanion(emoji: Value(emoji)));

  @override
  Future<void> deleteTag(int id) {
    return _db.transaction(() async {
      final affected = await _db.searchIndex.notesWithTag(id);
      await (_db.delete(_db.tags)..where((t) => t.id.equals(id))).go();
      await _db.searchIndex.reindexNotesWithTag(id, noteIds: affected);
    });
  }

  @override
  Stream<Map<int, int>> watchUsageCounts() {
    final count = _db.noteTags.noteId.count();
    final query = _db.selectOnly(_db.noteTags)
      ..addColumns([_db.noteTags.tagId, count])
      ..groupBy([_db.noteTags.tagId]);
    return query
        .watch()
        .map(
          (rows) => {
            for (final r in rows)
              r.read(_db.noteTags.tagId)!: r.read(count) ?? 0,
          },
        )
        .distinctMaps();
  }

  Future<void> _ensureUnique(String name, {int? exceptId}) async {
    if (name.isEmpty) throw ArgumentError.value(name, 'name', 'empty');
    final lower = name.toLowerCase();
    final existing = await _db.select(_db.tags).get();
    if (existing.any(
      (t) => t.id != exceptId && t.name.toLowerCase() == lower,
    )) {
      throw DuplicateTagNameException(name);
    }
  }
}
