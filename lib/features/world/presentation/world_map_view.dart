import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/news_labels.dart';
import '../../../shared/models/news_models.dart';
import '../../../shared/providers/app_providers.dart';
import '../data/country_geojson.dart';
import 'choropleth_map.dart';
import 'country_detail_panel.dart';

/// Interactive world overview with Natural Earth public-domain polygons
/// (see `docs/architecture/map_geojson.md`), severity hatch+icons (not colour alone),
/// zoom/pan, country detail panel, and an accessible country list alternative.
class WorldMapView extends ConsumerStatefulWidget {
  const WorldMapView({
    required this.countries,
    required this.stories,
    super.key,
  });

  final List<CountryNewsStatus> countries;
  final List<StoryCluster> stories;

  @override
  ConsumerState<WorldMapView> createState() => _WorldMapViewState();
}

class _WorldMapViewState extends ConsumerState<WorldMapView> {
  bool _showList = false;
  String? _selectedRegion;
  String? _selectedCountryCode;
  late final Future<CountryGeoCollection> _geoFuture =
      CountryGeoJsonRepository().load();

  @override
  Widget build(BuildContext context) {
    final filteredCountries = _selectedRegion == null
        ? widget.countries
        : widget.countries
              .where((c) => c.region == _selectedRegion)
              .toList(growable: false);

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _showList ? 'Country list' : 'World map',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Semantics(
              button: true,
              label: _showList
                  ? 'Show map view'
                  : 'Show accessible country list',
              child: TextButton.icon(
                onPressed: () => setState(() => _showList = !_showList),
                icon: Icon(_showList ? Icons.map_outlined : Icons.list_alt),
                label: Text(_showList ? 'Map' : 'Country list'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Made with Natural Earth (public domain). Severity uses colour, hatch, and icons — not colour alone.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Semantics(
          label: 'Filter countries by region',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('All regions'),
                selected: _selectedRegion == null,
                onSelected: (_) => setState(() => _selectedRegion = null),
              ),
              for (final region in _regions)
                FilterChip(
                  label: Text(_shortRegion(region)),
                  selected: _selectedRegion == region,
                  onSelected: (_) => setState(() => _selectedRegion = region),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const _SeverityLegend(),
        const SizedBox(height: 12),
        if (_showList)
          _CountryListAlternative(
            countries: filteredCountries,
            regionFilter: _selectedRegion,
            onOpen: (country) => _openCountrySheet(context, country),
            onFilterCountry: (code) {
              ref.read(storyFilterProvider.notifier).state = ref
                  .read(storyFilterProvider)
                  .copyWith(countryCode: code);
            },
            onClearRegion: _selectedRegion == null
                ? null
                : () => setState(() => _selectedRegion = null),
          )
        else
          FutureBuilder<CountryGeoCollection>(
            future: _geoFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(
                  'Map polygons failed to load. Use Country list. (${snapshot.error})',
                  style: Theme.of(context).textTheme.bodyMedium,
                );
              }
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return ChoroplethMap(
                geo: snapshot.data!,
                countries: filteredCountries,
                selectedCode: _selectedCountryCode,
                onSelect: (country) => _openCountrySheet(context, country),
              );
            },
          ),
      ],
    );
  }

  void _openCountrySheet(BuildContext context, CountryNewsStatus country) {
    setState(() => _selectedCountryCode = country.code);
    final countryStories = widget.stories
        .where(
          (story) =>
              story.primaryCountryCode == country.code ||
              story.countryCodes.contains(country.code),
        )
        .toList();

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: CountryDetailPanel(
            country: country,
            stories: countryStories,
            onFilterFeed: () {
              ref.read(storyFilterProvider.notifier).state = ref
                  .read(storyFilterProvider)
                  .copyWith(countryCode: country.code, region: country.region);
              Navigator.pop(context);
            },
          ),
        ),
      ),
    ).whenComplete(() {
      if (mounted) {
        setState(() => _selectedCountryCode = null);
      }
    });
  }

  static const _regions = [
    'Africa',
    'Asia',
    'Europe',
    'Middle East',
    'North America',
    'Latin America and the Caribbean',
    'Oceania',
  ];

  String _shortRegion(String region) => switch (region) {
    'Latin America and the Caribbean' => 'LatAm & Caribbean',
    'Middle East' => 'Middle East',
    'North America' => 'N. America',
    _ => region,
  };
}

class _SeverityLegend extends StatelessWidget {
  const _SeverityLegend();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Severity legend. Severity is shown with icons, text labels, map colour, and hatch patterns — not colour alone.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              for (final severity in Severity.values)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _icon(severity),
                      size: 18,
                      color: AppSemanticColors.severity(
                        severity,
                        Theme.of(context).brightness,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(severity.label),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Map polygons also use denser hatch for higher severity.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  static IconData _icon(Severity severity) => switch (severity) {
    Severity.critical => Icons.warning_amber,
    Severity.serious => Icons.priority_high,
    Severity.developing => Icons.update,
    Severity.general => Icons.info_outline,
  };
}

enum _CountryListSort { severity, name, activeStories }

/// Accessible alternative to the marker map: search, sort, and text+icon severity.
class _CountryListAlternative extends StatefulWidget {
  const _CountryListAlternative({
    required this.countries,
    required this.onOpen,
    required this.onFilterCountry,
    this.regionFilter,
    this.onClearRegion,
  });

  final List<CountryNewsStatus> countries;
  final String? regionFilter;
  final ValueChanged<CountryNewsStatus> onOpen;
  final ValueChanged<String> onFilterCountry;
  final VoidCallback? onClearRegion;

  @override
  State<_CountryListAlternative> createState() =>
      _CountryListAlternativeState();
}

class _CountryListAlternativeState extends State<_CountryListAlternative> {
  final _searchController = TextEditingController();
  _CountryListSort _sort = _CountryListSort.severity;
  bool _activeOnly = false;
  Severity? _severityFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CountryNewsStatus> get _visible {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = widget.countries.where((country) {
      if (_activeOnly && country.activeStoryCount <= 0) {
        return false;
      }
      if (_severityFilter != null &&
          country.currentSeverity != _severityFilter) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      final haystack = '${country.name} ${country.code} ${country.region}'
          .toLowerCase();
      return haystack.contains(query);
    }).toList();

    filtered.sort((a, b) {
      switch (_sort) {
        case _CountryListSort.name:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case _CountryListSort.activeStories:
          final byCount = b.activeStoryCount.compareTo(a.activeStoryCount);
          if (byCount != 0) return byCount;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case _CountryListSort.severity:
          final bySeverity = a.currentSeverity.index.compareTo(
            b.currentSeverity.index,
          );
          if (bySeverity != 0) return bySeverity;
          final byCount = b.activeStoryCount.compareTo(a.activeStoryCount);
          if (byCount != 0) return byCount;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
    });
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    final total = widget.countries.length;

    return Semantics(
      container: true,
      label: 'Accessible country list alternative to the world map',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Browse countries with search and sorting. Severity is shown as '
            'icons and text, not colour alone.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          SearchBar(
            controller: _searchController,
            hintText: 'Search countries or regions',
            leading: const Icon(Icons.search),
            trailing: [
              if (_searchController.text.isNotEmpty)
                IconButton(
                  tooltip: 'Clear country search',
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                ),
            ],
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              DropdownMenu<_CountryListSort>(
                key: ValueKey(_sort),
                initialSelection: _sort,
                label: const Text('Sort by'),
                onSelected: (value) {
                  if (value != null) {
                    setState(() => _sort = value);
                  }
                },
                dropdownMenuEntries: const [
                  DropdownMenuEntry(
                    value: _CountryListSort.severity,
                    label: 'Severity',
                  ),
                  DropdownMenuEntry(
                    value: _CountryListSort.name,
                    label: 'Name A–Z',
                  ),
                  DropdownMenuEntry(
                    value: _CountryListSort.activeStories,
                    label: 'Active stories',
                  ),
                ],
              ),
              FilterChip(
                label: const Text('Active stories only'),
                selected: _activeOnly,
                onSelected: (selected) =>
                    setState(() => _activeOnly = selected),
              ),
              for (final severity in Severity.values)
                FilterChip(
                  avatar: Icon(_icon(severity), size: 16),
                  label: Text(severity.label),
                  selected: _severityFilter == severity,
                  onSelected: (selected) => setState(
                    () => _severityFilter = selected ? severity : null,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Semantics(
            liveRegion: true,
            label: visible.isEmpty
                ? 'No countries match the current list filters'
                : 'Showing ${visible.length} of $total countries',
            child: Text(
              visible.isEmpty
                  ? 'No countries match these list filters.'
                  : 'Showing ${visible.length} of $total countries',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          if (visible.isEmpty) ...[
            const SizedBox(height: 12),
            Text(
              widget.regionFilter != null
                  ? 'Try clearing the region chip or search, or show all severities.'
                  : 'Try clearing search, severity chips, or “Active stories only”.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                TextButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _activeOnly = false;
                      _severityFilter = null;
                      _sort = _CountryListSort.severity;
                    });
                  },
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reset list filters'),
                ),
                if (widget.onClearRegion != null)
                  TextButton.icon(
                    onPressed: widget.onClearRegion,
                    icon: const Icon(Icons.public),
                    label: const Text('All regions'),
                  ),
              ],
            ),
          ] else
            for (final country in visible)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ExcludeSemantics(
                  child: Icon(
                    _icon(country.currentSeverity),
                    color: AppSemanticColors.severity(
                      country.currentSeverity,
                      Theme.of(context).brightness,
                    ),
                  ),
                ),
                title: Text(country.name),
                subtitle: Text(
                  '${country.region} • ${country.currentSeverity.label} severity • '
                  '${country.activeStoryCount} active • ${country.positiveStoryCount} positive',
                ),
                isThreeLine: true,
                trailing: IconButton(
                  tooltip: 'Filter feed to ${country.name}',
                  icon: const Icon(Icons.filter_alt_outlined),
                  onPressed: () => widget.onFilterCountry(country.code),
                ),
                onTap: () => widget.onOpen(country),
              ),
        ],
      ),
    );
  }

  IconData _icon(Severity severity) => switch (severity) {
    Severity.critical => Icons.warning_amber,
    Severity.serious => Icons.priority_high,
    Severity.developing => Icons.update,
    Severity.general => Icons.info_outline,
  };
}
