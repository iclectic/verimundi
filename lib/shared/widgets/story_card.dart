import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/date_formatters.dart';
import '../../features/stories/data/underreported_scoring_service.dart';
import '../models/news_models.dart';
import '../providers/app_providers.dart';
import 'status_pill.dart';

class StoryCard extends ConsumerWidget {
  const StoryCard({required this.story, this.contextNote, super.key});

  final StoryCluster story;
  final String? contextNote;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/stories/${story.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      story.headline,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Semantics(
                    label: story.isSaved
                        ? 'Remove ${story.headline} from saved stories'
                        : 'Save ${story.headline}',
                    button: true,
                    child: IconButton(
                      tooltip: story.isSaved
                          ? 'Remove saved story'
                          : 'Save story',
                      icon: Icon(
                        story.isSaved ? Icons.bookmark : Icons.bookmark_border,
                      ),
                      onPressed: () async {
                        final saved = ref.read(savedStoriesRepositoryProvider);
                        if (story.isSaved) {
                          await saved.remove(story.id);
                        } else {
                          await saved.save(story);
                        }
                        ref.invalidate(storiesProvider);
                        ref.invalidate(underreportedStoriesProvider);
                        ref.invalidate(positiveStoriesProvider);
                        ref.invalidate(storyByIdProvider(story.id));
                        ref.invalidate(savedSnapshotsProvider);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  SeverityPill(
                    severity: story.severity,
                    reason: story.severityReason,
                  ),
                  TonePill(tone: story.tone),
                  Chip(label: Text(story.verificationStatus.name)),
                  Chip(label: Text('${story.sourceCount} sources')),
                  if (story.isDemoContent) const Chip(label: Text('Demo data')),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${story.primaryCountryCode} • ${story.region} • ${story.category.name}',
              ),
              const SizedBox(height: 8),
              Text(story.shortSummary),
              const SizedBox(height: 8),
              Text(
                '${story.localSourceCount} local, ${story.regionalSourceCount} regional, ${story.internationalSourceCount} international sources • ${DateFormatters.relative(story.lastUpdatedAt)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (contextNote != null) ...[
                const SizedBox(height: 8),
                Text(
                  contextNote!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String underreportedNote(StoryCluster story) =>
    const UnderreportedScoringService().explanation(story);
