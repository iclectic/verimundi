import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/news_labels.dart';
import '../../../shared/models/news_models.dart';
import '../../../shared/widgets/status_pill.dart';

/// Country detail content for map/list selection — severity uses icon + text, not colour alone.
class CountryDetailPanel extends StatelessWidget {
  const CountryDetailPanel({
    required this.country,
    required this.stories,
    required this.onFilterFeed,
    super.key,
  });

  final CountryNewsStatus country;
  final List<StoryCluster> stories;
  final VoidCallback onFilterFeed;

  @override
  Widget build(BuildContext context) {
    final underreported = [...stories]
      ..sort((a, b) => b.underreportedScore.compareTo(a.underreportedScore));
    final positive = stories.where((s) => s.tone == Tone.positive).toList();
    final updated = DateFormat.yMMMd().add_Hm().format(country.lastUpdated.toLocal());

    return Semantics(
      container: true,
      label:
          '${country.name} country detail. ${country.currentSeverity.name} severity. '
          '${country.activeStoryCount} active stories.',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: Icon(
                  _severityIcon(country.currentSeverity),
                  color: AppSemanticColors.severity(
                    country.currentSeverity,
                    Theme.of(context).brightness,
                  ),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      country.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${country.code} · ${country.region}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SeverityPill(
                severity: country.currentSeverity,
                reason:
                    'Highest active severity for ${country.name} (icon and label, not colour alone)',
              ),
              Chip(
                avatar: const Icon(Icons.article_outlined, size: 16),
                label: Text('${country.activeStoryCount} active'),
              ),
              Chip(
                avatar: const Icon(Icons.volunteer_activism_outlined, size: 16),
                label: Text('${country.positiveStoryCount} positive'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Latest country update $updated',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Text(
            'Leading developments',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          if (stories.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'No linked stories are currently loaded for ${country.name}.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            for (final story in stories.take(4))
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ExcludeSemantics(
                  child: Icon(
                    _severityIcon(story.severity),
                    color: AppSemanticColors.severity(
                      story.severity,
                      Theme.of(context).brightness,
                    ),
                  ),
                ),
                title: Text(story.headline),
                subtitle: Text(
                  '${story.severity.label} · ${story.severityReason}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/stories/${story.id}');
                },
              ),
          if (underreported.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Underreported highlight',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(underreported.first.headline),
            Text(
              underreported.first.underreportedReason,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (positive.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Positive developments',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(positive.first.headline),
          ],
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: onFilterFeed,
            icon: const Icon(Icons.filter_alt_outlined),
            label: Text('Filter feed to ${country.name}'),
          ),
        ],
      ),
    );
  }

  static IconData _severityIcon(Severity severity) => switch (severity) {
    Severity.critical => Icons.warning_amber,
    Severity.serious => Icons.priority_high,
    Severity.developing => Icons.update,
    Severity.general => Icons.info_outline,
  };
}
