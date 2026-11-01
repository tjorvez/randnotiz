// FROZEN for the v5 → v6 migration. Do not edit: changing this table would
// change what an old database turns into. New suggestions belong in
// `features/tags/domain/mood_emoji_suggestions.dart`.

/// Emoji that tags received when they lost their colour in schema v3.
const v6DefaultEmoji = '🙂';

/// Word stems (lower case, umlauts folded: ä→a, ö→o, ü→u, ß→ss) and the
/// emoji a Stimmung with such a name gets. The first matching row wins.
/// Only emojis from Unicode ≤ 12 (Android 10+ renders all of them).
const v6MoodEmojiRules = <(List<String>, String)>[
  (['glucklich', 'gluck', 'froh', 'frohlich', 'zufrieden'], '😊'),
  (['freude', 'lachen', 'lustig', 'spass'], '😄'),
  (['liebe', 'verliebt', 'romanti', 'herz'], '🥰'),
  (['ruhig', 'entspann', 'gelassen', 'frieden', 'chill'], '😌'),
  (['begeister', 'aufgeregt', 'wow', 'staun'], '🤩'),
  (['ausgelassen', 'feier', 'party', 'fest'], '🥳'),
  (['cool', 'lassig'], '😎'),
  (['dankbar', 'dank'], '🙏'),
  (['nachdenk', 'grubel', 'gedanke'], '🤔'),
  (['mude', 'schlaf', 'erschopf'], '😴'),
  (['langweil'], '🥱'),
  (['melanchol', 'wehmut', 'nostalg', 'sehnsucht'], '😔'),
  (['traurig', 'trauer', 'weinen'], '😢'),
  (['wut', 'wutend', 'arger', 'sauer'], '😠'),
  (['angst', 'angstlich', 'nervos', 'sorge', 'stress'], '😰'),
  (['krank'], '🤒'),
  (['stolz', 'stark', 'kraft', 'sport', 'training'], '💪'),
  (['familie', 'eltern', 'oma', 'opa'], '👪'),
  (['freund'], '🤝'),
  (['kind', 'baby'], '👶'),
  (['hochzeit'], '💍'),
  (['geburtstag'], '🎂'),
  (['weihnacht'], '🎄'),
  (['urlaub', 'reise', 'ferien'], '✈️'),
  (['abenteuer', 'entdeck'], '🧭'),
  (['wander', 'berg'], '⛰️'),
  (['strand', 'meer', 'baden'], '🏖️'),
  (['pflanze', 'garten', 'blume'], '🌱'),
  (['natur', 'wald'], '🌿'),
  (['essen', 'kochen', 'lecker'], '🍽️'),
  (['kaffee'], '☕'),
  (['musik', 'konzert'], '🎵'),
  (['arbeit', 'buro', 'job'], '💼'),
  (['schule', 'lernen', 'studium'], '📚'),
  (['hund'], '🐶'),
  (['katze'], '🐱'),
  (['sonne', 'sommer', 'vibe'], '☀️'),
  (['regen'], '🌧️'),
  (['schnee', 'winter'], '❄️'),
  (['herbst'], '🍂'),
  (['fruhling'], '🌸'),
];

/// The emoji for a v5 tag called [name], or null if no rule matches.
String? v6EmojiForMoodName(String name) {
  final words = _fold(name)
      .split(RegExp(r'[^a-z0-9]+'))
      .where((w) => w.isNotEmpty)
      .toList();
  for (final (stems, emoji) in v6MoodEmojiRules) {
    for (final word in words) {
      if (stems.any(word.startsWith)) return emoji;
    }
  }
  return null;
}

String _fold(String s) => s
    .toLowerCase()
    .replaceAll('ä', 'a')
    .replaceAll('ö', 'o')
    .replaceAll('ü', 'u')
    .replaceAll('ß', 'ss');
