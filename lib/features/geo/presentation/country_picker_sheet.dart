import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/search/fts_query.dart';
import '../../../core/search/text_normalize.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/geo.dart';

/// Lets the user pick a country (search by German or English name).
/// Returns its code, or null if dismissed.
Future<String?> showCountryPicker(BuildContext context, {String? selected}) =>
    showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => CountryPickerSheet(selected: selected),
    );

class CountryPickerSheet extends ConsumerStatefulWidget {
  const CountryPickerSheet({super.key, this.selected});

  final String? selected;

  @override
  ConsumerState<CountryPickerSheet> createState() => _CountryPickerState();
}

class _CountryPickerState extends ConsumerState<CountryPickerSheet> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final all = ref.watch(geoDatabaseProvider).value?.countries ?? const [];
    final tokens = queryTokens(_query.text);
    final language = Localizations.localeOf(context).languageCode;
    final countries =
        [
          for (final c in all)
            if (tokens.isEmpty ||
                c.names.any((name) => matchesAnyPrefix(name, tokens)))
              c,
        ]..sort(
          (a, b) =>
              foldForSearch(a.localName(language))
                  .compareTo(foldForSearch(b.localName(language))),
        );
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                l10n.countryPickerTitle,
                style: theme.textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: TextField(
                controller: _query,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: l10n.countryPickerSearch,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: countries.length,
                itemBuilder: (context, i) {
                  final c = countries[i];
                  return _CountryTile(
                    country: c,
                    selected: c.code == widget.selected,
                    onTap: () => Navigator.pop(context, c.code),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryTile extends StatelessWidget {
  const _CountryTile({
    required this.country,
    required this.selected,
    required this.onTap,
  });

  final Country country;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    final other = country.otherName(language);
    return ListTile(
      leading: Text(country.flag, style: const TextStyle(fontSize: 22)),
      title: Text(country.localName(language)),
      subtitle: other == null ? null : Text(other),
      selected: selected,
      trailing: selected ? const Icon(Icons.check) : null,
      onTap: onTap,
    );
  }
}
