/// A user-defined label for notes. In the UI it is called "Stimmung" (mood)
/// and shown with an emoji; several can be attached to one note.
class Tag {
  const Tag({required this.id, required this.name, required this.emoji});

  final int id;
  final String name;

  /// A single emoji (possibly several code points, e.g. with skin tone).
  final String emoji;

  /// "😊 Glücklich"
  String get label => '$emoji $name';

  @override
  bool operator ==(Object other) =>
      other is Tag &&
      other.id == id &&
      other.name == name &&
      other.emoji == emoji;

  @override
  int get hashCode => Object.hash(id, name, emoji);

  @override
  String toString() => 'Tag($id, $emoji $name)';
}

class DuplicateTagNameException implements Exception {
  const DuplicateTagNameException(this.name);
  final String name;

  @override
  String toString() => 'DuplicateTagNameException($name)';
}

abstract interface class TagRepository {
  Stream<List<Tag>> watchTags();

  /// Throws [DuplicateTagNameException] if a tag with the same name exists
  /// (case-insensitive).
  Future<Tag> createTag(String name, {required String emoji});

  Future<void> renameTag(int id, String name);

  Future<void> setEmoji(int id, String emoji);

  /// Deletes the tag and removes it from all notes. Notes stay.
  Future<void> deleteTag(int id);

  /// Number of notes using each tag, keyed by tag id.
  Stream<Map<int, int>> watchUsageCounts();
}
