import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/home_shell.dart';
import '../../../app/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/polaroid.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../notes/presentation/note_photo.dart';
import '../domain/collection.dart';
import 'collection_dialogs.dart';

/// Tab "Sammlungen": every collection as a little stack of polaroids.
/// Long-press a collection and drag it to change the order.
class CollectionsScreen extends ConsumerWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final collections = ref.watch(collectionsProvider);

    Future<void> create() async {
      final c = await createCollection(context, ref);
      if (c != null && context.mounted) {
        await context.push('/collection/${c.id}');
      }
    }

    return collections.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(child: Text(l10n.errorGeneric)),
      data: (list) {
        if (list.isEmpty) {
          return EmptyState(
            icon: Icons.collections_bookmark_outlined,
            title: l10n.collectionsEmptyTitle,
            body: l10n.collectionsEmptyBody,
            action: FilledButton.icon(
              onPressed: create,
              icon: const Icon(Icons.add),
              label: Text(l10n.collectionNew),
            ),
          );
        }
        return _CollectionGrid(
          collections: list,
          onCreate: create,
          onReorder: (ids) =>
              ref.read(collectionRepositoryProvider).reorder(ids),
        );
      },
    );
  }
}

/// The grid of collections. While a collection is dragged, the others make
/// room live; the new order is stored when it is dropped.
class _CollectionGrid extends StatefulWidget {
  const _CollectionGrid({
    required this.collections,
    required this.onCreate,
    required this.onReorder,
  });

  final List<Collection> collections;
  final VoidCallback onCreate;
  final Future<void> Function(List<int> orderedIds) onReorder;

  @override
  State<_CollectionGrid> createState() => _CollectionGridState();
}

class _CollectionGridState extends State<_CollectionGrid> {
  /// The shown order while dragging (ids); null otherwise.
  List<int>? _dragOrder;
  int? _dragged;

  /// A dropped order that the database has not reported back yet: shown
  /// meanwhile, so the tiles do not jump back for a moment.
  List<int>? _pending;

  @override
  void didUpdateWidget(_CollectionGrid old) {
    super.didUpdateWidget(old);
    final pending = _pending;
    if (pending != null && _sameOrder(pending)) _pending = null;
  }

  List<Collection> get _shown {
    final order = _dragOrder ?? _pending;
    if (order == null) return widget.collections;
    final byId = {for (final c in widget.collections) c.id: c};
    return [
      for (final id in order) ?byId[id],
      // Created meanwhile: at the end until the drag is over.
      for (final c in widget.collections)
        if (!order.contains(c.id)) c,
    ];
  }

  void _start(int id) => setState(() {
    _dragged = id;
    _dragOrder = [for (final c in _shown) c.id];
  });

  /// The dragged collection is over [targetId]: it takes that place.
  void _hover(int targetId) {
    final order = _dragOrder, dragged = _dragged;
    if (order == null || dragged == null || dragged == targetId) return;
    final to = order.indexOf(targetId);
    if (to < 0) return;
    setState(() {
      order
        ..remove(dragged)
        ..insert(to, dragged);
    });
  }

  void _end() {
    final order = _dragOrder;
    setState(() {
      _dragged = null;
      _dragOrder = null;
    });
    if (order != null && !_sameOrder(order)) _store(order);
  }

  void _store(List<int> order) {
    setState(() => _pending = order);
    unawaited(
      widget.onReorder(order).catchError((Object e) {
        debugPrint('Reordering collections failed: $e');
        if (mounted) setState(() => _pending = null);
      }),
    );
  }

  bool _sameOrder(List<int> order) =>
      order.length == widget.collections.length &&
      [for (final (i, c) in widget.collections.indexed) order[i] == c.id]
          .every((same) => same);

  /// Accessibility: moves [id] one place towards the start (-1) or end (1).
  void _move(int id, int step) {
    final order = [for (final c in _shown) c.id];
    final from = order.indexOf(id);
    final to = from + step;
    if (from < 0 || to < 0 || to >= order.length) return;
    order
      ..removeAt(from)
      ..insert(to, id);
    _store(order);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shown = _shown;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / 190).floor().clamp(2, 5);
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, floatingNavClearance),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 18,
            crossAxisSpacing: 16,
            childAspectRatio: 0.78,
          ),
          itemCount: shown.length + 1,
          // Tiles keep their state when they change places – above all the
          // dragged one, whose drag would otherwise be cancelled.
          findChildIndexCallback: (key) {
            if (key is! ValueKey<int>) return null;
            final i = shown.indexWhere((c) => c.id == key.value);
            return i < 0 ? null : i;
          },
          itemBuilder: (context, i) {
            if (i == shown.length) {
              return _NewCollectionTile(onTap: widget.onCreate);
            }
            final collection = shown[i];
            return _DraggableCollectionTile(
              key: ValueKey(collection.id),
              collection: collection,
              dragging: _dragged == collection.id,
              onDragStarted: () => _start(collection.id),
              onHover: () => _hover(collection.id),
              onDragEnd: _end,
              customActions: {
                if (i > 0)
                  CustomSemanticsAction(
                    label: l10n.collectionMoveEarlier,
                  ): () =>
                      _move(collection.id, -1),
                if (i < shown.length - 1)
                  CustomSemanticsAction(label: l10n.collectionMoveLater): () =>
                      _move(collection.id, 1),
              },
            );
          },
        );
      },
    );
  }
}

/// A collection tile that can be long-pressed and dragged onto another
/// tile's place.
class _DraggableCollectionTile extends StatelessWidget {
  const _DraggableCollectionTile({
    super.key,
    required this.collection,
    required this.dragging,
    required this.onDragStarted,
    required this.onHover,
    required this.onDragEnd,
    required this.customActions,
  });

  final Collection collection;
  final bool dragging;
  final VoidCallback onDragStarted;
  final VoidCallback onHover;
  final VoidCallback onDragEnd;
  final Map<CustomSemanticsAction, VoidCallback> customActions;

  @override
  Widget build(BuildContext context) {
    final tile = _CollectionTile(
      collection: collection,
      customActions: customActions,
    );
    return LayoutBuilder(
      builder: (context, constraints) => DragTarget<int>(
        onWillAcceptWithDetails: (details) {
          if (details.data != collection.id) onHover();
          return details.data != collection.id;
        },
        builder: (context, _, _) => LongPressDraggable<int>(
          data: collection.id,
          onDragStarted: onDragStarted,
          onDragEnd: (_) => onDragEnd(),
          feedback: SizedBox.fromSize(
            size: constraints.biggest,
            // Lifted off the desk: a little larger and tilted.
            child: Transform.rotate(
              angle: -0.03,
              child: Transform.scale(
                scale: 1.06,
                child: Material(type: MaterialType.transparency, child: tile),
              ),
            ),
          ),
          childWhenDragging: const SizedBox.shrink(),
          child: AnimatedOpacity(
            opacity: dragging ? 0 : 1,
            duration: const Duration(milliseconds: 120),
            child: tile,
          ),
        ),
      ),
    );
  }
}

class _CollectionTile extends StatelessWidget {
  const _CollectionTile({
    required this.collection,
    this.customActions = const {},
  });

  final Collection collection;
  final Map<CustomSemanticsAction, VoidCallback> customActions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label:
          '${collection.name}, ${l10n.collectionEntryCount(collection.noteCount)}',
      hint: l10n.collectionsReorderHint,
      customSemanticsActions: customActions,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/collection/${collection.id}'),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: CollectionCoverStack(collection: collection)),
              const SizedBox(height: 10),
              Text(
                collection.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: AppFonts.serif,
                ),
              ),
              Text(
                l10n.collectionEntryCount(collection.noteCount),
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Up to three polaroids, fanned out like a small pile on the desk.
class CollectionCoverStack extends StatelessWidget {
  const CollectionCoverStack({super.key, required this.collection});

  final Collection collection;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final covers = collection.covers;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest.shortestSide * 0.78;
        final cacheWidth = (size * MediaQuery.devicePixelRatioOf(context))
            .round();
        if (covers.isEmpty) {
          return Center(
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: scheme.outlineVariant, width: 1.5),
              ),
              child: Icon(
                Icons.collections_bookmark_outlined,
                color: scheme.outline,
              ),
            ),
          );
        }
        const tilts = [-7.0, 6.0, -1.5];
        final shown = covers.reversed.toList(); // newest on top
        return Stack(
          alignment: Alignment.center,
          children: [
            for (final (i, cover) in shown.indexed)
              Transform.translate(
                offset: Offset(
                  (shown.length - 1 - i) * (i.isEven ? -6.0 : 6.0),
                  (shown.length - 1 - i) * -3.0,
                ),
                child: SizedBox(
                  width: size,
                  child: Polaroid(
                    tilt: tilts[(shown.length - 1 - i) % tilts.length],
                    tape: i == shown.length - 1,
                    image: NotePhoto(
                      assetId: cover.assetId,
                      thumbnailFile: cover.thumbnailFile,
                      preferStoredCopy: true,
                      cacheWidth: cacheWidth,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _NewCollectionTile extends StatelessWidget {
  const _NewCollectionTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: scheme.outlineVariant,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(Icons.add, color: scheme.secondary, size: 30),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.collectionNew,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
