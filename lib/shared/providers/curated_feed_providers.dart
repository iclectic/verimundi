import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/cache/cache_freshness.dart';
import '../../core/network/remote_api_exception.dart';
import '../../features/stories/data/feed_cache_repository.dart';
import '../../features/stories/data/story_filtering.dart';
import '../models/news_models.dart';
import 'core_providers.dart';
import 'feed_cache_keys.dart';
import 'feed_providers.dart';
import 'saved_providers.dart';

/// Offline-aware list used by dedicated underreported / positive screens.
///
/// World Pulse [FeedMode] segments still filter/sort the main [storiesFeedProvider]
/// client-side; these providers hit `/v1/stories/underreported|positive` (or mock
/// equivalents) so nav screens stay authoritative for those catalogues.
class CachedStoriesListState {
  const CachedStoriesListState({
    required this.stories,
    required this.freshness,
    required this.cacheLabel,
    this.fromCache = false,
  });

  final List<StoryCluster> stories;
  final CacheFreshness freshness;
  final String cacheLabel;
  final bool fromCache;
}

/// Shared fetch → cache → typed remote fallback for curated lists.
Future<CachedStoriesListState> loadCuratedStoriesList({
  required Future<List<StoryCluster>> Function() fetch,
  required FeedCacheRepository cache,
  required String cacheKey,
  required Set<String> savedIds,
  List<StoryCluster> Function(List<StoryCluster> stories)? transform,
}) async {
  try {
    final stories = await fetch();
    final transformed = transform == null ? stories : transform(stories);
    final marked = transformed
        .map((story) => story.copyWith(isSaved: savedIds.contains(story.id)))
        .toList();
    await cache.saveStories(
      cacheKey: cacheKey,
      stories: marked,
      sourceMode: FeedCacheKeys.sourceMode,
      total: marked.length,
    );
    return CachedStoriesListState(
      stories: marked,
      freshness: CacheFreshness.fresh,
      cacheLabel: 'Live feed',
    );
  } on RemoteApiException {
    final cached = await cache.readStories(cacheKey);
    if (cached != null) {
      return CachedStoriesListState(
        stories: cached.stories
            .map(
              (story) => story.copyWith(isSaved: savedIds.contains(story.id)),
            )
            .toList(),
        freshness: cached.freshness,
        cacheLabel: cached.label,
        fromCache: true,
      );
    }
    rethrow;
  }
}

final underreportedStoriesProvider = FutureProvider<CachedStoriesListState>((
  ref,
) async {
  final repository = ref.watch(newsRepositoryProvider);
  final cache = ref.watch(feedCacheRepositoryProvider);
  final filter = ref.watch(storyFilterProvider);
  final savedIds = await ref
      .watch(savedStoriesRepositoryProvider)
      .getSavedStoryIds();
  final cacheKey = FeedCacheKeys.underreported(filter);

  return loadCuratedStoriesList(
    fetch: repository.getUnderreportedStories,
    cache: cache,
    cacheKey: cacheKey,
    savedIds: savedIds,
    transform: (stories) {
      const filtering = StoryFiltering();
      return filtering.apply(stories, filter);
    },
  );
});

final positiveStoriesProvider = FutureProvider<CachedStoriesListState>((
  ref,
) async {
  final repository = ref.watch(newsRepositoryProvider);
  final cache = ref.watch(feedCacheRepositoryProvider);
  final savedIds = await ref
      .watch(savedStoriesRepositoryProvider)
      .getSavedStoryIds();
  final cacheKey = FeedCacheKeys.positive;

  return loadCuratedStoriesList(
    fetch: repository.getPositiveStories,
    cache: cache,
    cacheKey: cacheKey,
    savedIds: savedIds,
  );
});
