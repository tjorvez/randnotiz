import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/music_service.dart';
import '../domain/preview_player.dart';

/// What the preview player is doing (app-wide, one preview at a time).
final previewStateProvider = StreamProvider<PreviewState>(
  (ref) => ref.watch(previewPlayerProvider).states,
);

/// A message for a failed music action ([search]: while searching).
String musicErrorText(
  AppLocalizations l10n,
  Object error, {
  bool search = false,
}) {
  final status = error is MusicException ? error.httpStatus : null;
  // Apple answers 403 (sometimes 429) when a client asks too often.
  if (status == 403 || status == 429) return l10n.songErrorRateLimit;
  return switch (error is MusicException ? error.code : '') {
    MusicException.network => l10n.songErrorNetwork,
    MusicException.notFound => l10n.songErrorNotFound,
    MusicException.noPreview => l10n.songErrorNoPreview,
    _ => search ? l10n.songErrorSearch : l10n.songErrorPlayback,
  };
}

void showMusicMessage(BuildContext context, String text) {
  ScaffoldMessenger.maybeOf(context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

void showMusicError(BuildContext context, Object error) => showMusicMessage(
  context,
  musicErrorText(AppLocalizations.of(context), error),
);

/// Opens [url] outside the app (Apple Music, song.link). Reports a failure
/// in a snackbar.
Future<void> openMusicLink(BuildContext context, Future<Uri> url) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    final opened = await launchUrl(
      await url,
      mode: LaunchMode.externalApplication,
    );
    if (!opened) {
      messenger?.showSnackBar(SnackBar(content: Text(l10n.songErrorOpen)));
    }
  } on MusicException catch (e) {
    messenger?.showSnackBar(SnackBar(content: Text(musicErrorText(l10n, e))));
  } on Exception catch (e) {
    debugPrint('Opening music link failed: $e');
    messenger?.showSnackBar(SnackBar(content: Text(l10n.songErrorOpen)));
  }
}

/// Opens the song [uri] in Apple Music.
void openInAppleMusic(BuildContext context, WidgetRef ref, String uri) {
  final music = ref.read(musicServiceProvider);
  unawaited(openMusicLink(context, music.links(uri).then((l) => l.storeUrl)));
}

/// Opens the song [uri] on song.link, which offers it in other services.
void openInOtherServices(BuildContext context, WidgetRef ref, String uri) {
  final music = ref.read(musicServiceProvider);
  unawaited(openMusicLink(context, Future.value(music.otherServicesUrl(uri))));
}
