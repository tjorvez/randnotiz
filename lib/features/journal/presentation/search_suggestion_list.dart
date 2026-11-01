import 'package:flutter/material.dart';

import '../../../app/home_shell.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../notes/domain/note.dart';
import '../../tags/domain/tag.dart';
import '../domain/search_suggestions.dart';

/// The suggestions shown while typing in the journal search, grouped into
/// Stimmungen, places, countries and earlier searches. Choosing one sets a
/// filter (or, for an earlier search, the search text).
class SearchSuggestionList extends StatelessWidget {
  const SearchSuggestionList({
    super.key,
    required this.suggestions,
    required this.onTag,
    required this.onPlace,
    required this.onCountry,
    required this.onRecent,
    required this.onRemoveRecent,
    required this.onClearRecent,
  });

  final SearchSuggestions suggestions;
  final ValueChanged<Tag> onTag;
  final ValueChanged<PlaceUse> onPlace;
  final ValueChanged<String> onCountry;
  final ValueChanged<String> onRecent;
  final ValueChanged<String> onRemoveRecent;
  final VoidCallback onClearRecent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = suggestions;
    return ListView(
      padding: const EdgeInsets.only(bottom: floatingNavClearance),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        if (s.tags.isNotEmpty) ...[
          _Header(l10n.suggestionsTags),
          for (final t in s.tags)
            _Item(
              leading: Text(t.emoji, style: const TextStyle(fontSize: 20)),
              title: t.name,
              onTap: () => onTag(t),
            ),
        ],
        if (s.places.isNotEmpty) ...[
          _Header(l10n.suggestionsPlaces),
          for (final p in s.places)
            _Item(
              leading: const Icon(Icons.place_outlined),
              title: p.name,
              trailing: l10n.journalResultCount(p.count),
              onTap: () => onPlace(p),
            ),
        ],
        if (s.countries.isNotEmpty) ...[
          _Header(l10n.suggestionsCountries),
          for (final (c, count) in s.countries)
            _Item(
              leading: Text(c.flag, style: const TextStyle(fontSize: 20)),
              title: c.nameDe,
              subtitle: c.nameEn == c.nameDe ? null : c.nameEn,
              trailing: l10n.journalResultCount(count),
              onTap: () => onCountry(c.code),
            ),
        ],
        if (s.recent.isNotEmpty) ...[
          _Header(
            l10n.suggestionsRecent,
            action: TextButton(
              onPressed: onClearRecent,
              child: Text(l10n.suggestionsClearRecent),
            ),
          ),
          for (final r in s.recent)
            _Item(
              leading: const Icon(Icons.history),
              title: r,
              onTap: () => onRecent(r),
              onRemove: () => onRemoveRecent(r),
              removeTooltip: l10n.suggestionsRemoveRecent,
            ),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.title, {this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 12, 2),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.leading,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.onRemove,
    this.removeTooltip,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final String? trailing;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  final String? removeTooltip;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 24, right: 12),
      leading: SizedBox(width: 28, child: Center(child: leading)),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: onRemove != null
          ? IconButton(
              tooltip: removeTooltip,
              icon: const Icon(Icons.close, size: 20),
              onPressed: onRemove,
            )
          : trailing == null
          ? null
          : Text(trailing!, style: TextStyle(color: muted, fontSize: 13)),
      onTap: onTap,
    );
  }
}
