import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/music_service.dart';

/// What the music feature can do here (asked once per app start).
final musicStatusProvider = FutureProvider<MusicStatus>(
  (ref) => ref.watch(musicServiceProvider).status(),
);

/// What Spotify is playing right now (with App Remote only).
final playbackProvider = StreamProvider<PlaybackState>(
  (ref) => ref.watch(musicServiceProvider).playback,
);

/// A message for a failed music action ([search]: while searching).
String musicErrorText(
  AppLocalizations l10n,
  Object error, {
  bool search = false,
}) {
  final code = error is MusicException ? error.code : '';
  final status = error is MusicException ? error.httpStatus : null;
  if (status == 403) return l10n.songErrorForbidden;
  if (status == 429) return l10n.songErrorRateLimit;
  if (status == 401) return l10n.songErrorNotAuthorized;
  return switch (code) {
    MusicException.notInstalled => l10n.songErrorNotInstalled,
    MusicException.notLoggedIn => l10n.songErrorNotLoggedIn,
    MusicException.notAuthorized ||
    MusicException.notConfigured => l10n.songErrorNotAuthorized,
    MusicException.cancelled => l10n.songErrorCancelled,
    MusicException.network || MusicException.offline => l10n.songErrorNetwork,
    _ => search ? l10n.songErrorSearch : l10n.songErrorPlayback,
  };
}

/// The technical details of a failed music action, for diagnosis.
String musicErrorDetail(Object error) => switch (error) {
  MusicException(:final code, :final detail) =>
    detail == null ? code : '$code: $detail',
  _ => '$error',
};

void showMusicError(BuildContext context, Object error) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  messenger
    ?..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(musicErrorText(AppLocalizations.of(context), error)),
      ),
    );
}
