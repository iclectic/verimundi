import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../core/cache/cache_freshness.dart';
import '../../core/network/remote_api_exception.dart';
import '../models/news_models.dart';
import 'core_providers.dart';
import 'feed_cache_keys.dart';
import 'saved_providers.dart';

final storyFilterProvider = StateProvider<StoryFilter>(
  (ref) => const StoryFilter(),
);

final feedModeProvider = StateProvider<FeedMode>((ref) => FeedMode.worldPulse);

final feedPageProvider = StateProvider<int>((ref) => 1);

class StoriesFeedState {
  const StoriesFeedState({
    required this.stories,
    required this.freshness,
    required this.cacheLabel,
    required this.page,
    required this.pageSize,
    required this.total,
    this.fromCache = false,
    this.usedSearchEndpoint = false,
  });

  final List<StoryCluster> stories;
  final CacheFreshness freshness;
  final String cacheLabel;
  final int page;
  final int pageSize;
  final int total;
  final bool fromCache;
  final bool usedSearchEndpoint;

  bool get hasMore => page * pageSize < total;
  int get totalPages => pageSize <= 0
      ? 1
      : ((total + pageSize - 1) ~/ pageSize).clamp(1, 1 << 30);
}

final storiesFeedProvider = FutureProvider<StoriesFeedState>((ref) async {
  final repository = ref.watch(newsRepositoryProvider);
  final cache = ref.watch(feedCacheRepositoryProvider);
  final savedIds = await ref
      .watch(savedStoriesRepositoryProvider)
      .getSavedStoryIds();
  final filter = ref.watch(storyFilterProvider);
  final page = ref.watch(feedPageProvider);
  final pagedFilter = filter.copyWith(page: page < 1 ? 1 : page);
  final usedSearch =
      pagedFilter.query != null && pagedFilter.query!.trim().isNotEmpty;
  final cacheKey = FeedCacheKeys.stories(
    usedSearch: usedSearch,
    page: page < 1 ? 1 : page,
    filter: pagedFilter,
  );

  try {
    final result = await repository.getStories(pagedFilter);
    final marked = result.stories
        .map((story) => story.copyWith(isSaved: savedIds.contains(story.id)))
        .toList();
    await cache.saveStories(
      cacheKey: cacheKey,
      stories: marked,
      sourceMode: FeedCacheKeys.sourceMode,
      total: result.total,
      page: result.page,
      pageSize: result.pageSize,
    );
    return StoriesFeedState(
      stories: marked,
      freshness: CacheFreshness.fresh,
      cacheLabel: usedSearch ? 'Live search' : 'Live feed',
      page: result.page,
      pageSize: result.pageSize,
      total: result.total,
      usedSearchEndpoint: usedSearch,
    );
  } on RemoteApiException {
    final cached = await cache.readStories(cacheKey);
    if (cached != null) {
      final resolvedPage = cached.page ?? (page < 1 ? 1 : page);
      final resolvedPageSize = cached.pageSize ?? pagedFilter.pageSize;
      return StoriesFeedState(
        stories: cached.stories
            .map(
              (story) => story.copyWith(isSaved: savedIds.contains(story.id)),
            )
            .toList(),
        freshness: cached.freshness,
        cacheLabel: cached.label,
        fromCache: true,
        page: resolvedPage,
        pageSize: resolvedPageSize,
        total: cached.total,
        usedSearchEndpoint: usedSearch,
      );
    }
    rethrow;
  }
});

/// Backwards-compatible stories list used by existing screens/tests.
final storiesProvider = FutureProvider<List<StoryCluster>>((ref) async {
  final feed = await ref.watch(storiesFeedProvider.future);
  return feed.stories;
});

final countriesProvider = FutureProvider<List<CountryNewsStatus>>((ref) {
  return ref.watch(newsRepositoryProvider).getCountryStatuses();
});

final storyByIdProvider = FutureProvider.family<StoryCluster?, String>((
  ref,
  id,
) async {
  final story = await ref.watch(newsRepositoryProvider).getStoryById(id);
  if (story == null) return null;
  final saved = await ref.watch(savedStoriesRepositoryProvider).isSaved(id);
  return story.copyWith(isSaved: saved);
});
