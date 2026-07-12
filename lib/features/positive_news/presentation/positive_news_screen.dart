import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/demo_banner.dart';
import '../../../shared/widgets/story_card.dart';

class PositiveNewsScreen extends ConsumerWidget {
  const PositiveNewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stories = ref.watch(positiveStoriesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Positive World')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(positiveStoriesProvider),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const DemoBanner(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: AsyncValueView(
                value: stories,
                builder: (items) => Column(
                  children: [
                    for (final story in items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: StoryCard(
                          story: story,
                          contextNote:
                              'Positive impact score ${story.positiveImpactScore.toStringAsFixed(0)} with confidence ${(story.confidenceScore * 100).toStringAsFixed(0)}%. This describes a constructive development without claiming the issue is solved.',
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
