import 'dart:math';

import 'package:drift/drift.dart';

final _uidRandom = Random.secure();

/// A random 128-bit id as 32 hex digits – the stable identity of a note or
/// collection across devices (schema v10). Row ids and the MediaStore asset
/// id differ after a restore on another phone; the uid does not.
String newUid() => List.generate(
  16,
  (_) => _uidRandom.nextInt(256).toRadixString(16).padLeft(2, '0'),
).join();

/// A diary note attached to exactly one photo of the device gallery.
@DataClassName('NoteRow')
@TableIndex(name: 'notes_note_date_idx', columns: {#noteDate})
class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Stable id across devices (schema v10), see [newUid].
  TextColumn get uid => text().unique().clientDefault(newUid)();

  /// MediaStore asset id of the photo (photo_manager `AssetEntity.id`).
  TextColumn get assetId => text().unique()();

  TextColumn get body => text().withDefault(const Constant(''))();

  /// Optional title (schema v6), handwritten on the polaroid's rim.
  TextColumn get title => text().nullable()();

  /// Width / height of the photo as shown (EXIF orientation applied),
  /// schema v6. Lets every polaroid of the note have exactly the same
  /// proportions, so the photo can fly between them without distortion.
  /// Null if unknown (treated as square).
  RealColumn get photoAspect => real().nullable()();

  /// The date shown in the note header. Initialised with the capture date of
  /// the photo, editable by the user. Used for grouping and memories.
  DateTimeColumn get noteDate => dateTime()();

  /// Name of a `WeatherKind` value, or null if no weather is known.
  TextColumn get weatherKind => text().nullable()();

  RealColumn get temperatureC => real().nullable()();

  /// Optional place (schema v4), e.g. "Hamburg": typed in, or the nearest
  /// town of the photo's GPS position (offline, schema v7). Only the name is
  /// stored, never coordinates.
  TextColumn get placeName => text().nullable()();

  /// The English/international name of [placeName] if it differs
  /// ("Munich" for "München", schema v7) – searchable as well.
  TextColumn get placeNameAlt => text().nullable()();

  /// ISO 3166-1 alpha-2 code of the country (schema v7), e.g. "NO".
  TextColumn get countryCode => text().nullable()();

  /// Country/place were looked up (or set by hand) – the one-time
  /// back-fill skips this note (schema v7).
  BoolColumn get geoChecked => boolean().withDefault(const Constant(false))();

  /// File name (not path) of the downscaled JPEG copy inside the app's
  /// thumbnail directory. Keeps the entry alive if the original is deleted.
  TextColumn get thumbnailFile => text().nullable()();

  /// Optional song (schema v8): Spotify URI, title, artist (searchable)
  /// and the file name of the stored cover. All null without a song.
  TextColumn get songUri => text().nullable()();
  TextColumn get songTitle => text().nullable()();
  TextColumn get songArtist => text().nullable()();
  TextColumn get songCoverFile => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// A label for notes, shown to the user as "Stimmung" (mood) with an emoji.
@DataClassName('TagRow')
class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 40).unique()();

  /// One emoji (may consist of several code points). Added in schema v3,
  /// replacing the former colour.
  TextColumn get emoji => text().withDefault(const Constant(defaultTagEmoji))();
}

/// Emoji for tags created before schema v3.
const defaultTagEmoji = '🙂';

@DataClassName('NoteTagRow')
class NoteTags extends Table {
  IntColumn get noteId =>
      integer().references(Notes, #id, onDelete: KeyAction.cascade)();
  IntColumn get tagId =>
      integer().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {noteId, tagId};
}

/// Country names for the search index (schema v7), filled from the bundled
/// geodata at start-up – so "Norwegen" and "Norway" find the same notes.
@DataClassName('CountryRow')
class Countries extends Table {
  TextColumn get code => text().withLength(min: 2, max: 2)();
  TextColumn get nameDe => text()();
  TextColumn get nameEn => text()();

  @override
  Set<Column<Object>> get primaryKey => {code};
}

/// A collection ("Sammlung") of notes, e.g. a trip (schema v5).
@DataClassName('CollectionRow')
class Collections extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Stable id across devices (schema v10), see [newUid].
  TextColumn get uid => text().unique().clientDefault(newUid)();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  DateTimeColumn get createdAt => dateTime()();

  /// Place in the overview (ascending), set by dragging. A new collection
  /// gets a position before all others, so it appears first.
  IntColumn get position => integer().withDefault(const Constant(0))();
}

/// Membership of a note in a collection. Entries are ordered by note date.
@DataClassName('CollectionNoteRow')
class CollectionNotes extends Table {
  IntColumn get collectionId =>
      integer().references(Collections, #id, onDelete: KeyAction.cascade)();
  IntColumn get noteId =>
      integer().references(Notes, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get addedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {collectionId, noteId};
}
