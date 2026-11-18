import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import 'music_providers.dart';

/// Apple's official "Listen on Apple Music" badge in the app's language,
/// linking to the song. Apple's terms want covers and previews from its
/// Search API shown next to this badge – so it goes wherever a linked song
/// is shown.
class AppleMusicBadge extends ConsumerWidget {
  const AppleMusicBadge({super.key, required this.songUri, this.height = 32});

  /// The badge artwork for [languageCode] (English for any other) and its
  /// width / height. Rendered unchanged from Apple Marketing Tools
  /// (`listen-on-apple-music/badge`, 120 px high).
  static (String, double) artworkFor(String languageCode) =>
      switch (languageCode) {
        'de' => ('assets/branding/apple_music_badge_de.png', 419 / 120),
        'fr' => ('assets/branding/apple_music_badge_fr.png', 419 / 120),
        'es' => ('assets/branding/apple_music_badge_es.png', 419 / 120),
        _ => ('assets/branding/apple_music_badge_en.png', 412 / 120),
      };

  final String songUri;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = AppLocalizations.of(context).songOpenAppleMusic;
    final (asset, aspect) = artworkFor(
      Localizations.localeOf(context).languageCode,
    );
    return Semantics(
      link: true,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: InkWell(
          key: const ValueKey('appleMusicBadge'),
          borderRadius: BorderRadius.circular(height * 0.2),
          onTap: () => openInAppleMusic(context, ref, songUri),
          child: Image.asset(
            asset,
            height: height,
            width: height * aspect,
            filterQuality: FilterQuality.medium,
          ),
        ),
      ),
    );
  }
}
