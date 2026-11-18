import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/features/tags/domain/mood_emoji_suggestions.dart';

void main() {
  test('names get a fitting emoji, umlauts and case do not matter', () {
    expect(suggestMoodEmoji('Pflanzen'), '🌱');
    expect(suggestMoodEmoji('glücklich'), '😊');
    expect(suggestMoodEmoji('GLUECKLICH'), isNull, reason: 'ue is not folded');
    expect(suggestMoodEmoji('Müde'), '😴');
    expect(suggestMoodEmoji('Ausgelassen'), '🥳');
    expect(suggestMoodEmoji('Mit Freunden'), '🤝');
    expect(suggestMoodEmoji('Melancholie'), '😔');
    expect(suggestMoodEmoji('Frühling'), '🌸');
  });

  test('English, French and Spanish names too, accents do not matter', () {
    expect(suggestMoodEmoji('Happy'), '😊');
    expect(suggestMoodEmoji('Tired'), '😴');
    expect(suggestMoodEmoji('Beach day'), '🏖️');
    expect(suggestMoodEmoji('Fatigué'), '😴');
    expect(suggestMoodEmoji('Fatigue'), '😴');
    expect(suggestMoodEmoji('En colère'), '😠');
    expect(suggestMoodEmoji('Anniversaire'), '🎂');
    expect(suggestMoodEmoji('Avec des amis'), '🤝');
    expect(suggestMoodEmoji('Feliz'), '😊');
    expect(suggestMoodEmoji('Playa'), '🏖️');
    expect(suggestMoodEmoji('Otoño'), '🍂');
    expect(suggestMoodEmoji('Con mi familia'), '👪');
  });

  test('a stem of one language does not catch common words of another', () {
    expect(suggestMoodEmoji('Wonderful'), isNull);
    expect(suggestMoodEmoji('Fortschritt'), isNull);
    expect(suggestMoodEmoji('Merveilleux'), isNull);
  });

  test('unknown names get no suggestion', () {
    expect(suggestMoodEmoji(''), isNull);
    expect(suggestMoodEmoji('Xyz'), isNull);
  });
}
