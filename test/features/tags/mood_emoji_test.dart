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

  test('unknown names get no suggestion', () {
    expect(suggestMoodEmoji(''), isNull);
    expect(suggestMoodEmoji('Xyz'), isNull);
  });
}
