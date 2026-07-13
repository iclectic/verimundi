import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/news_models.dart';

class WorldMapView extends StatelessWidget {
  const WorldMapView({
    required this.countries,
    required this.stories,
    super.key,
  });

  final List<CountryNewsStatus> countries;
  final List<StoryCluster> stories;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'World map with country severity markers',
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.public,
                      size: constraints.maxHeight * 0.65,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
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
                            '${country.name}, ${country.currentSeverity.name} severity, ${country.activeStoryCount} active stories',
                        child: IconButton.filledTonal(
                          tooltip:
                              '${country.name}: ${country.currentSeverity.name}',
                          icon: Icon(
                            _severityIcon(country.currentSeverity),
                            size: 18,
                          ),
                          color: AppSemanticColors.severity(
                            country.currentSeverity,
                            Theme.of(context).brightness,
                          ),
                          onPressed: () => _openCountrySheet(context, country),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _openCountrySheet(BuildContext context, CountryNewsStatus country) {
    final leading = stories
        .where((story) => story.countryCodes.contains(country.code))
        .take(3)
        .toList();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(country.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              '${country.currentSeverity.name} severity • ${country.activeStoryCount} active stories • ${country.positiveStoryCount} positive developments',
            ),
            const SizedBox(height: 16),
            for (final story in leading)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(story.headline),
                subtitle: Text(story.severityReason),
              ),
          ],
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
