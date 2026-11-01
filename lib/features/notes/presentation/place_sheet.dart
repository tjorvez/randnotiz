import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/format/formatters.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../geo/presentation/country_picker_sheet.dart';
import '../../weather/domain/place_search.dart';
import '../../weather/domain/weather.dart';
import '../../weather/presentation/weather_ui.dart';
import 'note_editor_controller.dart';

/// Bottom sheet for a note's country and place. Both are filled in from the
/// photo's GPS data when there is some (offline) and can be changed or
/// removed here. With a place (or GPS in the photo) the weather of that day
/// is shown; it can also be adjusted by hand. Only names are stored, never
/// coordinates.
class PlaceSheet extends ConsumerStatefulWidget {
  const PlaceSheet({super.key, required this.assetId});

  final String assetId;

  static Future<void> show(BuildContext context, String assetId) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        useSafeArea: true,
        builder: (_) => PlaceSheet(assetId: assetId),
      );

  @override
  ConsumerState<PlaceSheet> createState() => _PlaceSheetState();
}

class _PlaceSheetState extends ConsumerState<PlaceSheet> {
  final _query = TextEditingController();
  final _temperature = TextEditingController();
  Timer? _debounce;
  List<Place> _places = const [];
  bool _searching = false;
  bool _searched = false;

  NoteEditorController get _controller =>
      ref.read(noteEditorProvider(widget.assetId).notifier);

  @override
  void initState() {
    super.initState();
    final t = ref
        .read(noteEditorProvider(widget.assetId))
        .weather
        ?.temperatureC;
    if (t != null) _temperature.text = Fmt.temperature(t);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    _temperature.dispose();
    super.dispose();
  }

  void _onQueryChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => unawaited(_search(text)),
    );
  }

  Future<void> _search(String text) async {
    if (text.trim().length < 2) {
      setState(() {
        _places = const [];
        _searched = false;
      });
      return;
    }
    setState(() => _searching = true);
    final results = await ref.read(placeSearchProvider).search(text);
    if (!mounted || text != _query.text) return;
    setState(() {
      _places = results;
      _searching = false;
      _searched = true;
    });
  }

  double? _parsedTemperature() =>
      double.tryParse(_temperature.text.trim().replaceAll(',', '.'));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(noteEditorProvider(widget.assetId));
    final weather = state.weather;
    // Fill in the temperature of a fetched result (not while typing).
    ref.listen(noteEditorProvider(widget.assetId), (prev, next) {
      final t = next.weather?.temperatureC;
      if (next.weatherLookup == WeatherLookup.done &&
          prev?.weather != next.weather &&
          t != null) {
        _temperature.text = Fmt.temperature(t);
      }
    });

    final Widget weatherLine = switch (state.weatherLookup) {
      WeatherLookup.loading => Row(
        children: [
          const SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Text(l10n.weatherLoading),
        ],
      ),
      WeatherLookup.failed => Text(l10n.weatherOffline),
      _ when weather != null => Row(
        children: [
          Icon(
            weatherIcon(weather.kind),
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(weatherLabel(l10n, weather))),
        ],
      ),
      _ => Text(l10n.placeWeatherHint),
    };

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Text(l10n.placeSheetTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          _CountryRow(
            countryCode: state.countryCode,
            onPick: () async {
              final code = await showCountryPicker(
                context,
                selected: state.countryCode,
              );
              if (code != null) _controller.setCountry(code);
            },
            onRemove: () => _controller.setCountry(null),
          ),
          if (state.placeName != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.place, color: theme.colorScheme.primary),
              title: Text(state.placeName!),
              trailing: TextButton(
                onPressed: _controller.clearPlace,
                child: Text(l10n.placeRemove),
              ),
            ),
          TextField(
            controller: _query,
            onChanged: _onQueryChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: l10n.placeSearchHint,
              helperText: l10n.placePrivacy,
              helperMaxLines: 3,
              suffixIcon: _searching
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
              border: const OutlineInputBorder(),
            ),
          ),
          if (_searched && _places.isEmpty && !_searching)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(l10n.placeNoResults),
            ),
          for (final place in _places)
            ListTile(
              dense: true,
              leading: const Icon(Icons.place_outlined),
              title: Text(place.label),
              onTap: () {
                unawaited(_controller.setPlace(place));
                Navigator.pop(context);
              },
            ),
          const SizedBox(height: 20),
          Text(l10n.weatherAdd, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          weatherLine,
          if (state.photo != null &&
              state.photoHasLocation != false &&
              state.placeName == null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: state.weatherLookup == WeatherLookup.loading
                    ? null
                    : _controller.lookupWeatherFromPhoto,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.weatherFetchAgain),
              ),
            ),
          Theme(
            data: theme.copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 8),
              title: Text(l10n.weatherAdjust),
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final kind in WeatherKind.values)
                      ChoiceChip(
                        avatar: Icon(weatherIcon(kind), size: 18),
                        label: Text(l10n.weatherKind(kind.name)),
                        selected: weather?.kind == kind,
                        onSelected: (_) => _controller.setWeatherManually(
                          WeatherSnapshot(
                            kind: kind,
                            temperatureC: _parsedTemperature(),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _temperature,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[-0-9,.]')),
                  ],
                  decoration: InputDecoration(
                    labelText: l10n.weatherTemperatureLabel,
                    border: const OutlineInputBorder(),
                    suffixText: '°C',
                  ),
                  onChanged: (_) {
                    final w = ref
                        .read(noteEditorProvider(widget.assetId))
                        .weather;
                    if (w != null) {
                      _controller.setWeatherManually(
                        w.copyWith(temperatureC: _parsedTemperature),
                      );
                    }
                  },
                ),
                if (weather != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        _controller.setWeatherManually(null);
                        _temperature.clear();
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: Text(l10n.weatherRemove),
                    ),
                  ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.done),
            ),
          ),
        ],
      ),
    );
  }
}

/// The note's country: flag and name, change and remove.
class _CountryRow extends ConsumerWidget {
  const _CountryRow({
    required this.countryCode,
    required this.onPick,
    required this.onRemove,
  });

  final String? countryCode;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final country = ref.watch(geoDatabaseProvider).value?.country(countryCode);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: country == null
          ? Icon(Icons.public, color: theme.colorScheme.outline)
          : Text(country.flag, style: const TextStyle(fontSize: 22)),
      title: Text(country?.nameDe ?? l10n.countryNone),
      subtitle: Text(l10n.countryLabel),
      onTap: onPick,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: onPick,
            child: Text(country == null ? l10n.countryAdd : l10n.countryChange),
          ),
          if (country != null)
            IconButton(
              tooltip: l10n.countryRemove,
              icon: const Icon(Icons.close),
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}
