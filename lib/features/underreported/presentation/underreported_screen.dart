import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/demo_banner.dart';
import '../../../shared/widgets/filter_bar.dart';
import '../../../shared/widgets/story_card.dart';

class UnderreportedScreen extends ConsumerWidget {
  const UnderreportedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stories = ref.watch(underreportedStoriesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Underreported')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(underreportedStoriesProvider),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const DemoBanner(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FilterBar(),
                  const SizedBox(height: 16),
                  AsyncValueView(
                    value: stories,
                    builder: (items) => Column(
                      children: [
                        for (final story in items)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: StoryCard(
                              story: story,
                              contextNote: underreportedNote(story),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
