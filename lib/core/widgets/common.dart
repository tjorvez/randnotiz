import 'package:flutter/material.dart';

import '../../features/tags/domain/tag.dart';
import '../search/highlight.dart';
import '../theme/app_theme.dart';

/// Text with search hits highlighted (marker format of `highlight.dart`).
class HighlightedText extends StatelessWidget {
  const HighlightedText(this.marked, {super.key, this.style, this.maxLines});

  final String marked;
  final TextStyle? style;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final base = style ?? DefaultTextStyle.of(context).style;
    final highlight = context.diary.highlight;
    return Text.rich(
      TextSpan(
        children: [
          for (final part in parseHighlights(marked))
            TextSpan(
              text: part.text,
              style: part.isMatch
                  ? base.copyWith(
                      backgroundColor: highlight,
                      fontWeight: FontWeight.w700,
                    )
                  : null,
            ),
        ],
      ),
      style: base,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
    );
  }
}

/// Friendly empty state with an icon, a title and some text.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.action,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: theme.colorScheme.secondary),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              body,
              textAlign: TextAlign.center,
              style: AppTheme.noteText(
                context,
                size: 18,
              ).copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}

/// A Stimmung (tag) as a small label: emoji and name.
class TagLabel extends StatelessWidget {
  const TagLabel({super.key, required this.tag, this.highlighted = false});

  final Tag tag;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: highlighted
            ? context.diary.highlight
            : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Text(
        tag.label,
        style: TextStyle(fontSize: 12.5, color: scheme.onSurface, height: 1.3),
      ),
    );
  }
}
