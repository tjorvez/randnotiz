import '../../../core/database/migrations/v6_mood_emojis.dart';

/// Emoji offered for a new Stimmung before the user picks one.
const defaultMoodEmoji = '😊';

/// Suggests an emoji that fits a Stimmung called [name] ("Pflanzen" → 🌱),
/// or null if none fits.
///
/// Uses the same word table as the v6 migration for now. That table is
/// frozen – to change the suggestions, copy it into this file first.
String? suggestMoodEmoji(String name) => v6EmojiForMoodName(name);
