import '../../../core/search/text_normalize.dart';

/// Emoji offered for a new Stimmung before the user picks one.
const defaultMoodEmoji = '😊';

/// Suggests an emoji that fits a Stimmung called [name] ("Pflanzen" → 🌱,
/// "Happy" → 😊, "Fatigué" → 😴, "Playa" → 🏖️), or null if none fits.
///
/// One table for all languages of the app: a name matches if one of its
/// words starts with a stem, whatever the language. (The v6 migration has
/// its own frozen, German-only copy in `v6_mood_emojis.dart`.)
String? suggestMoodEmoji(String name) {
  final words = splitWords(foldForSearch(name));
  for (final (stems, emoji) in moodEmojiRules) {
    for (final word in words) {
      if (stems.any(word.startsWith)) return emoji;
    }
  }
  return null;
}

/// Word stems (folded: lower case, no accents, ß → ss) and the emoji a
/// Stimmung with such a name gets; the first matching row wins. Stems are
/// German, English, French and Spanish; very short ones that would match
/// unrelated words in another language ("mer", "sol", "chat", "fort") are
/// left out.
/// Only emojis from Unicode ≤ 12 (Android 10+ renders all of them).
const moodEmojiRules = <(List<String>, String)>[
  (
    [
      'glucklich', 'gluck', 'froh', 'frohlich', 'zufrieden', //
      'happy', 'glad', 'content', //
      'heureu', //
      'feliz', 'alegr',
    ],
    '😊',
  ),
  (
    [
      'freude', 'lachen', 'lustig', 'spass', //
      'joy', 'fun', 'laugh', //
      'joie', 'rire', 'drole', //
      'risa', 'divert',
    ],
    '😄',
  ),
  (
    [
      'liebe', 'verliebt', 'romanti', 'herz', //
      'love', //
      'amour', 'amoureu', //
      'amor', 'enamor',
    ],
    '🥰',
  ),
  (
    [
      'ruhig', 'entspann', 'gelassen', 'frieden', 'chill', //
      'calm', 'relax', 'peace', //
      'detend', 'serein', 'tranquil', //
      'relaj', 'paz',
    ],
    '😌',
  ),
  (
    [
      'begeister', 'aufgeregt', 'wow', 'staun', //
      'excit', 'amaz', //
      'emerveill', //
      'emocion', 'ilusion',
    ],
    '🤩',
  ),
  (
    [
      'ausgelassen', 'feier', 'party', 'fest', //
      'celebrat', //
      'fete', //
      'fiesta', 'celebr',
    ],
    '🥳',
  ),
  (['cool', 'lassig', 'genial'], '😎'),
  (
    [
      'dankbar', 'dank', //
      'grateful', 'thank', //
      'reconnaiss', 'merci', //
      'agradec', 'gracias',
    ],
    '🙏',
  ),
  (
    [
      'nachdenk', 'grubel', 'gedanke', //
      'thought', 'pensive', //
      'pensif', 'reflech', //
      'pensativ', 'reflexi',
    ],
    '🤔',
  ),
  (
    [
      'mude', 'schlaf', 'erschopf', //
      'tired', 'sleep', 'exhaust', //
      'fatigu', 'sommeil', 'epuis', //
      'cansad', 'sueno', 'agotad',
    ],
    '😴',
  ),
  (['langweil', 'bored', 'boring', 'ennui', 'aburr'], '🥱'),
  (
    [
      'melanchol', 'wehmut', 'nostalg', 'sehnsucht', //
      'longing', 'missing', //
      'manque', //
      'anoranz',
    ],
    '😔',
  ),
  (
    [
      'traurig', 'trauer', 'weinen', //
      'sad', 'cry', 'grief', //
      'triste', 'pleur', 'chagrin', //
      'llor', 'pena',
    ],
    '😢',
  ),
  (
    [
      'wut', 'wutend', 'arger', 'sauer', //
      'angry', 'anger', 'annoy', 'furious', //
      'colere', 'fache', 'enerve', //
      'enfad', 'enoj', 'furios',
    ],
    '😠',
  ),
  (
    [
      'angst', 'angstlich', 'nervos', 'sorge', 'stress', //
      'fear', 'afraid', 'anxi', 'nervous', 'worr', 'scared', //
      'peur', 'inquiet', 'angoiss', //
      'mied', 'ansied', 'nervio', 'preocup',
    ],
    '😰',
  ),
  (['krank', 'sick', 'malade', 'enferm'], '🤒'),
  (
    [
      'stolz', 'stark', 'kraft', 'sport', 'training', //
      'proud', 'strong', 'workout', 'gym', //
      'fier', //
      'orgull', 'fuerte', 'deporte', 'entren',
    ],
    '💪',
  ),
  (
    [
      'familie', 'eltern', 'oma', 'opa', //
      'family', 'parents', 'grandma', 'grandpa', //
      'famille', 'mamie', 'papi', 'grand-mere', //
      'familia', 'padres', 'abuel',
    ],
    '👪',
  ),
  (['freund', 'friend', 'ami', 'amig'], '🤝'),
  (
    [
      'kind', 'baby', //
      'child', 'kid', //
      'enfant', 'bebe', //
      'nino', 'hij',
    ],
    '👶',
  ),
  (['hochzeit', 'wedding', 'mariage', 'boda'], '💍'),
  (['geburtstag', 'birthday', 'anniversaire', 'cumple'], '🎂'),
  (['weihnacht', 'christmas', 'xmas', 'noel', 'navidad'], '🎄'),
  (
    [
      'urlaub', 'reise', 'ferien', //
      'holiday', 'vacation', 'travel', 'trip', //
      'vacance', 'voyage', //
      'vacacion', 'viaje',
    ],
    '✈️',
  ),
  (['abenteuer', 'entdeck', 'adventure', 'explor', 'aventur'], '🧭'),
  (
    [
      'wander', 'berg', //
      'hik', 'mountain', //
      'randonn', 'montagne', //
      'senderism', 'montan',
    ],
    '⛰️',
  ),
  (
    [
      'strand', 'meer', 'baden', //
      'beach', 'sea', 'swim', //
      'plage', 'nager', 'natation', //
      'playa', 'nadar',
    ],
    '🏖️',
  ),
  (
    [
      'pflanze', 'garten', 'blume', //
      'plant', 'garden', 'flower', //
      'jardin', 'fleur', //
      'planta',
    ],
    '🌱',
  ),
  (['natur', 'wald', 'forest', 'foret', 'bosque'], '🌿'),
  (
    [
      'essen', 'kochen', 'lecker', //
      'food', 'cook', 'yummy', 'delicious', //
      'manger', 'cuisine', 'delicieu', 'repas', //
      'comida', 'cocin', 'delicios',
    ],
    '🍽️',
  ),
  (['kaffee', 'coffee', 'cafe'], '☕'),
  (['musik', 'konzert', 'music', 'musiq', 'concert', 'concierto'], '🎵'),
  (
    [
      'arbeit', 'buro', 'job', //
      'work', 'office', //
      'travail', 'bureau', 'boulot', //
      'trabaj', 'oficina',
    ],
    '💼',
  ),
  (
    [
      'schule', 'lernen', 'studium', //
      'school', 'study', 'learn', //
      'ecole', 'etude', 'apprend', //
      'escuela', 'estudi', 'aprend',
    ],
    '📚',
  ),
  (['hund', 'dog', 'chien', 'perro'], '🐶'),
  (['katze', 'cat', 'chaton', 'gato'], '🐱'),
  (
    [
      'sonne', 'sommer', 'vibe', //
      'sun', 'summer', //
      'soleil', //
      'verano', 'soleado',
    ],
    '☀️',
  ),
  (['regen', 'rain', 'pluie', 'lluvia'], '🌧️'),
  (['schnee', 'winter', 'snow', 'neige', 'hiver', 'nieve', 'invierno'], '❄️'),
  (['herbst', 'autumn', 'automne', 'otono'], '🍂'),
  (['fruhling', 'spring', 'printemps', 'primavera'], '🌸'),
];
