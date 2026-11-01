import 'package:drift/drift.dart';

/// Keeps the `notes_fts` table in sync with notes and tag names.
///
/// The index stores the note text, the names of its tags (joined by " · "),
/// the place names (German and English), the title and the country names
/// (German and English) and title + artist of the song, keyed by `rowid = notes.id`. All writes to notes/tags go through
/// the repositories, which call these helpers inside their transactions.
class SearchIndex {
  const SearchIndex(this._db);

  final GeneratedDatabase _db;

  static const _selectSource = '''
SELECT n.id, n.body,
  COALESCE((SELECT group_concat(t.name, ' · ')
            FROM note_tags nt JOIN tags t ON t.id = nt.tag_id
            WHERE nt.note_id = n.id), ''),
  TRIM(COALESCE(n.place_name, '') || ' ' || COALESCE(n.place_name_alt, '')),
  COALESCE(n.title, ''),
  COALESCE((SELECT c.name_de || ' ' || c.name_en
            FROM countries c WHERE c.code = n.country_code), ''),
  TRIM(COALESCE(n.song_title, '') || ' ' || COALESCE(n.song_artist, ''))
FROM notes n''';

  /// Rebuilds the whole index (used by the v1→v2 migration).
  Future<void> rebuildAll() async {
    await _db.customStatement('DELETE FROM notes_fts');
    await _db.customStatement(
      'INSERT INTO notes_fts(rowid, body, tags, place, title, country, song) '
      '$_selectSource',
    );
  }

  Future<void> reindexNote(int noteId) async {
    await _db.customStatement('DELETE FROM notes_fts WHERE rowid = ?', [
      noteId,
    ]);
    await _db.customStatement(
      'INSERT INTO notes_fts(rowid, body, tags, place, title, country, song) '
      '$_selectSource WHERE n.id = ?',
      [noteId],
    );
  }

  Future<void> removeNote(int noteId) =>
      _db.customStatement('DELETE FROM notes_fts WHERE rowid = ?', [noteId]);

  /// Re-indexes every note carrying [tagId] (after rename/delete of a tag).
  Future<void> reindexNotesWithTag(int tagId, {List<int>? noteIds}) async {
    final ids = noteIds ?? await notesWithTag(tagId);
    for (final id in ids) {
      await reindexNote(id);
    }
  }

  Future<List<int>> notesWithTag(int tagId) async {
    final rows = await _db
        .customSelect(
          'SELECT note_id FROM note_tags WHERE tag_id = ?',
          variables: [Variable.withInt(tagId)],
        )
        .get();
    return rows.map((r) => r.read<int>('note_id')).toList();
  }
}
