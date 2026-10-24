import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/news_models.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/status_pill.dart';

/// Interactive world overview. Full country polygons need a licensed GeoJSON
/// asset (Phase 8 external blocker); this view uses equirectangular markers,
/// regional severity tint bands, icons+labels (not colour alone), zoom/pan,
/// and an accessible country list alternative.
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
                'World map',
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
        Wrap(
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
        const SizedBox(height: 12),
        const _SeverityLegend(),
        const SizedBox(height: 12),
        if (_showList)
          _CountryListAlternative(
            countries: filteredCountries,
            stories: widget.stories,
            onOpen: (country) => _openCountrySheet(context, country),
            onFilterCountry: (code) {
              ref.read(storyFilterProvider.notifier).state = ref
                  .read(storyFilterProvider)
                  .copyWith(countryCode: code);
            },
          )
        else
          _InteractiveChoroplethMap(
            countries: filteredCountries,
            onSelect: (country) => _openCountrySheet(context, country),
          ),
      ],
    );
  }

  void _openCountrySheet(BuildContext context, CountryNewsStatus country) {
    final countryStories = widget.stories
        .where((story) => story.countryCodes.contains(country.code))
        .toList();
    final underreported = [...countryStories]
      ..sort((a, b) => b.underreportedScore.compareTo(a.underreportedScore));
    final positive = countryStories
        .where((s) => s.tone == Tone.positive)
        .toList();

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(country.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  SeverityPill(
                    severity: country.currentSeverity,
                    reason: 'Highest active severity for ${country.name}',
                  ),
                  Chip(label: Text('${country.activeStoryCount} active')),
                  Chip(label: Text('${country.positiveStoryCount} positive')),
                  Chip(label: Text(country.region)),
                ],
              ),
              const SizedBox(height: 8),
              Text('Latest update ${country.lastUpdated.toLocal()}'),
              const SizedBox(height: 16),
              Text(
                'Leading developments',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              for (final story in countryStories.take(3))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(story.headline),
                  subtitle: Text(story.severityReason),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/stories/${story.id}');
                  },
                ),
              if (underreported.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Underreported',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(underreported.first.headline),
              ],
              if (positive.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Positive developments',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(positive.first.headline),
              ],
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () {
                  ref.read(storyFilterProvider.notifier).state = ref
                      .read(storyFilterProvider)
                      .copyWith(
                        countryCode: country.code,
                        region: country.region,
                      );
                  Navigator.pop(context);
                },
                child: Text('Filter feed to ${country.name}'),
              ),
            ],
          ),
        ),
      ),
    );
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
          'Severity legend. Severity is also shown with icons and text labels.',
      child: Wrap(
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
                Text(severity.name),
              ],
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

class _InteractiveChoroplethMap extends StatelessWidget {
  const _InteractiveChoroplethMap({
    required this.countries,
    required this.onSelect,
  });

  final List<CountryNewsStatus> countries;
  final ValueChanged<CountryNewsStatus> onSelect;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Interactive world map with country severity markers. Use country list for an accessible alternative.',
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: _RegionTintPainter(
                      countries: countries,
                      brightness: Theme.of(context).brightness,
                      outline: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    child: Stack(
                      children: [
                        for (final country in countries)
                          Positioned(
                            left:
                                (((country.longitude + 180) / 360) *
                                            constraints.maxWidth -
                                        18)
                                    .clamp(0, constraints.maxWidth - 36),
                            top:
                                (((90 - country.latitude) / 180) *
                                            constraints.maxHeight -
                                        18)
                                    .clamp(0, constraints.maxHeight - 36),
                            child: Semantics(
                              button: true,
                              label:
                                  '${country.name}, ${country.currentSeverity.name} severity, ${country.activeStoryCount} active stories, region ${country.region}',
                              child: IconButton.filledTonal(
                                tooltip:
                                    '${country.name}: ${country.currentSeverity.name}, ${country.activeStoryCount} stories',
                                icon: Icon(
                                  _severityIcon(country.currentSeverity),
                                  size: 18,
                                ),
                                color: AppSemanticColors.severity(
                                  country.currentSeverity,
                                  Theme.of(context).brightness,
                                ),
                                onPressed: () => onSelect(country),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _severityIcon(Severity severity) => switch (severity) {
    Severity.critical => Icons.warning_amber,
    Severity.serious => Icons.priority_high,
    Severity.developing => Icons.update,
    Severity.general => Icons.info_outline,
  };
}

/// Soft regional tint bands as a choropleth stand-in until licensed GeoJSON lands.
class _RegionTintPainter extends CustomPainter {
  _RegionTintPainter({
    required this.countries,
    required this.brightness,
    required this.outline,
  });

  final List<CountryNewsStatus> countries;
  final Brightness brightness;
  final Color outline;

  @override
  void paint(Canvas canvas, Size size) {
    final byRegion = <String, Severity>{};
    for (final country in countries) {
      final current = byRegion[country.region];
      if (current == null || country.currentSeverity.index < current.index) {
        byRegion[country.region] = country.currentSeverity;
      }
    }

    // Approximate longitude bands for high-level regions.
    final bands = <String, (double, double)>{
      'North America': (-170, -50),
      'Latin America and the Caribbean': (-90, -30),
      'Europe': (-15, 40),
      'Africa': (-20, 55),
      'Middle East': (25, 65),
      'Asia': (60, 150),
      'Oceania': (110, 180),
    };

    for (final entry in bands.entries) {
      final severity = byRegion[entry.key] ?? Severity.general;
      final color = AppSemanticColors.severity(
        severity,
        brightness,
      ).withValues(alpha: 0.18);
      final left = ((entry.value.$1 + 180) / 360) * size.width;
      final right = ((entry.value.$2 + 180) / 360) * size.width;
      final rect = Rect.fromLTRB(
        left.clamp(0, size.width),
        size.height * 0.08,
        right.clamp(0, size.width),
        size.height * 0.92,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(12)),
        Paint()..color = color,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(12)),
        Paint()
          ..color = outline.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RegionTintPainter oldDelegate) =>
      oldDelegate.countries != countries ||
      oldDelegate.brightness != brightness;
}

class _CountryListAlternative extends StatelessWidget {
  const _CountryListAlternative({
    required this.countries,
    required this.stories,
    required this.onOpen,
    required this.onFilterCountry,
  });

  final List<CountryNewsStatus> countries;
  final List<StoryCluster> stories;
  final ValueChanged<CountryNewsStatus> onOpen;
  final ValueChanged<String> onFilterCountry;

  @override
  Widget build(BuildContext context) {
    final sorted = [...countries]
      ..sort((a, b) {
        final severity = a.currentSeverity.index.compareTo(
          b.currentSeverity.index,
        );
        if (severity != 0) return severity;
        return b.activeStoryCount.compareTo(a.activeStoryCount);
      });

    return Semantics(
      label: 'Accessible country list alternative to the world map',
      child: Column(
        children: [
          for (final country in sorted)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                _icon(country.currentSeverity),
                color: AppSemanticColors.severity(
                  country.currentSeverity,
                  Theme.of(context).brightness,
                ),
              ),
              title: Text(country.name),
              subtitle: Text(
                '${country.region} • ${country.currentSeverity.name} severity • '
                '${country.activeStoryCount} active • ${country.positiveStoryCount} positive',
              ),
              trailing: IconButton(
                tooltip: 'Filter to ${country.name}',
                icon: const Icon(Icons.filter_alt_outlined),
                onPressed: () => onFilterCountry(country.code),
              ),
              onTap: () => onOpen(country),
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
