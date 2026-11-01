import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import 'note_editor_controller.dart';

/// How the note page comes in.
enum NoteEntrance {
  /// From a list: fades in and rises slightly, the photo flies along.
  rise,

  /// The next entry of a collection: slides in from the right.
  next,

  /// The previous entry of a collection: slides in from the left.
  previous,
}

/// What the note route gets besides its location.
@immutable
class NoteRouteExtra {
  const NoteRouteExtra({this.entrance = NoteEntrance.rise, this.heroTag});

  final NoteEntrance entrance;

  /// Tag of the polaroid that was tapped (see `NoteHeroTag`); the note page
  /// uses the same tag so the polaroid flies into it. Null: no flight.
  final Object? heroTag;
}

/// Route location of a note, optionally within a collection.
String noteLocation(String assetId, {int? collectionId}) => Uri(
  path: '/note/${Uri.encodeComponent(assetId)}',
  queryParameters: collectionId == null
      ? null
      : {'collection': '$collectionId'},
).toString();

bool _opening = false;

/// Opens the note of [assetId].
///
/// The note is loaded *before* the page is pushed (usually a few
/// milliseconds, at most [maxWait]), so the page appears complete in its
/// first frame: no spinner, no layout jump, and the polaroid tagged
/// [heroTag] can fly from the list into the page. The stored copy of the
/// photo is decoded meanwhile: it is what flies, and what the page shows
/// first.
Future<void> openNote(
  BuildContext context,
  String assetId, {
  int? collectionId,
  NoteEntrance entrance = NoteEntrance.rise,
  Object? heroTag,
  Duration maxWait = const Duration(milliseconds: 300),
}) async {
  if (_opening) return; // double tap
  _opening = true;
  final container = ProviderScope.containerOf(context, listen: false);
  final router = GoRouter.of(context);
  final provider = noteEditorProvider(assetId);
  // Keeps the (auto-disposing) editor state alive until the page listens.
  final keepAlive = container.listen(provider, (_, _) {});
  final started = DateTime.now();
  try {
    if (keepAlive.read().loading) {
      final loaded = Completer<void>();
      final sub = container.listen(provider, (_, next) {
        if (!next.loading && !loaded.isCompleted) loaded.complete();
      });
      await loaded.future.timeout(maxWait, onTimeout: () {});
      sub.close();
    }
    final thumbnail = keepAlive.read().thumbnailFile;
    if (thumbnail != null && context.mounted) {
      final left = maxWait - DateTime.now().difference(started);
      if (left > Duration.zero) {
        final file = container.read(thumbnailStoreProvider).fileFor(thumbnail);
        await precacheImage(
          FileImage(file),
          context,
          onError: (_, _) {},
        ).timeout(left, onTimeout: () {});
      }
    }
    final location = noteLocation(assetId, collectionId: collectionId);
    final extra = NoteRouteExtra(entrance: entrance, heroTag: heroTag);
    if (entrance == NoteEntrance.rise) {
      unawaited(router.push(location, extra: extra));
    } else {
      unawaited(router.pushReplacement(location, extra: extra));
    }
    // Two frames later the page is built and watches the state itself.
    await WidgetsBinding.instance.endOfFrame;
    await WidgetsBinding.instance.endOfFrame;
  } finally {
    keepAlive.close();
    _opening = false;
  }
}
