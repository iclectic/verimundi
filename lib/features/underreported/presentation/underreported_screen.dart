import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/news_models.dart';
import '../../../shared/models/story_filter_extensions.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/app_status_banners.dart';
import '../../../shared/widgets/cache_status_banner.dart';
import '../../../shared/widgets/feed_empty_state.dart';
import '../../../shared/widgets/filter_bar.dart';
import '../../../shared/widgets/story_card.dart';

class UnderreportedScreen extends ConsumerWidget {
  const UnderreportedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedValue = ref.watch(underreportedStoriesProvider);
    final filter = ref.watch(storyFilterProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Underreported')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(underreportedStoriesProvider),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const AppStatusBanners(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FilterBar(),
                  const SizedBox(height: 16),
                  AsyncValueView(
                    value: feedValue,
                    empty: FeedEmptyState(
                      reason: filter.hasActiveConstraints
                          ? FeedEmptyReason.filteredOut
                          : FeedEmptyReason.noClusters,
                      mode: FeedMode.underreported,
                      onResetFilters: () {
                        ref.read(storyFilterProvider.notifier).state =
                            const StoryFilter();
                      },
                    ),
                    builder: (feed) {
                      if (feed.stories.isEmpty) {
                        return FeedEmptyState(
                          reason: filter.hasActiveConstraints
                              ? FeedEmptyReason.filteredOut
                              : FeedEmptyReason.noClusters,
                          mode: FeedMode.underreported,
                          onResetFilters: () {
                            ref.read(storyFilterProvider.notifier).state =
                                const StoryFilter();
                          },
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (feed.fromCache)
                            CacheStatusBanner(
                              label: feed.cacheLabel,
                              freshness: feed.freshness,
                            ),
                          for (final story in feed.stories)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: StoryCard(
                                story: story,
                                contextNote: underreportedNote(story),
                              ),
                            ),
                        ],
                      );
                    },
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
