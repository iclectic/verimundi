import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../core/cache/cache_freshness.dart';
import '../../core/constants/app_constants.dart';
import '../../core/database/app_database.dart';
import '../../core/network/api_client.dart';
import '../../core/network/app_remote_config.dart';
import '../../features/saved/data/drift_saved_stories_repository.dart';
import '../../features/saved/data/saved_stories_repository.dart';
import '../../features/stories/data/feed_cache_repository.dart';
import '../../features/stories/data/mock_news_repository.dart';
import '../../features/stories/data/remote_news_repository.dart';
import '../../features/stories/data/story_filtering.dart';
import '../../features/stories/domain/news_repository.dart';
import '../../features/story_questions/data/mock_story_question_service.dart';
import '../../features/story_questions/data/remote_story_question_service.dart';
import '../../features/story_questions/domain/story_question_service.dart';
import '../models/news_models.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final remoteAppConfigProvider = FutureProvider<AppRemoteConfig?>((ref) async {
  final client = ref.watch(apiClientProvider);
  if (client.isMockMode) {
    return null;
  }
  try {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/v1/app/config',
    );
    final data = response.data;
    if (data == null) return null;
    return AppRemoteConfig.fromJson(data);
  } catch (_) {
    return null;
  }
});

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final inMemoryDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase.forTesting(NativeDatabase.memory());
  ref.onDispose(database.close);
  return database;
});

final feedCacheRepositoryProvider = Provider<FeedCacheRepository>((ref) {
  return FeedCacheRepository(ref.watch(databaseProvider));
});

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  if (client.isMockMode) {
    return MockNewsRepository();
  }
  return RemoteNewsRepository(client: client);
});

final savedStoriesRepositoryProvider = Provider<SavedStoriesRepository>((ref) {
  return DriftSavedStoriesRepository(ref.watch(databaseProvider));
});

final storyQuestionServiceProvider = Provider<StoryQuestionService>((ref) {
  final repository = ref.watch(newsRepositoryProvider);
  if (repository is RemoteNewsRepository) {
    return RemoteStoryQuestionService(repository);
  }
  return MockStoryQuestionService();
});

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
    this.fromCache = false,
  });

  final List<StoryCluster> stories;
  final CacheFreshness freshness;
  final String cacheLabel;
  final bool fromCache;
}

final storiesFeedProvider = FutureProvider<StoriesFeedState>((ref) async {
  final repository = ref.watch(newsRepositoryProvider);
  final cache = ref.watch(feedCacheRepositoryProvider);
  final savedIds = await ref
      .watch(savedStoriesRepositoryProvider)
      .getSavedStoryIds();
  final filter = ref.watch(storyFilterProvider);
  final page = ref.watch(feedPageProvider);
  final cacheKey =
      'stories:${AppConstants.isMockApi ? 'mock' : 'remote'}:$page:${filter.query}:${filter.region}:${filter.countryCode}:${filter.category}:${filter.severity}:${filter.tone}:${filter.verificationStatus}:${filter.hasLocalCoverage}';

  try {
    final stories = await repository.getStories(filter);
    final marked = stories
        .map((story) => story.copyWith(isSaved: savedIds.contains(story.id)))
        .toList();
    await cache.saveStories(
      cacheKey: cacheKey,
      stories: marked,
      sourceMode: AppConstants.isMockApi ? 'mock' : 'remote',
    );
    return StoriesFeedState(
      stories: marked,
      freshness: CacheFreshness.fresh,
      cacheLabel: 'Live feed',
    );
  } catch (_) {
    final cached = await cache.readStories(cacheKey);
    if (cached != null) {
      return StoriesFeedState(
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
});

/// Backwards-compatible stories list used by existing screens/tests.
final storiesProvider = FutureProvider<List<StoryCluster>>((ref) async {
  final feed = await ref.watch(storiesFeedProvider.future);
  return feed.stories;
});

final underreportedStoriesProvider = FutureProvider<List<StoryCluster>>((
  ref,
) async {
  final repository = ref.watch(newsRepositoryProvider);
  final filter = ref.watch(storyFilterProvider);
  final savedIds = await ref
      .watch(savedStoriesRepositoryProvider)
      .getSavedStoryIds();
  final stories = await repository.getUnderreportedStories();
  const filtering = StoryFiltering();
  return filtering
      .apply(stories, filter)
      .map((story) => story.copyWith(isSaved: savedIds.contains(story.id)))
      .toList();
});

final positiveStoriesProvider = FutureProvider<List<StoryCluster>>((ref) async {
  final repository = ref.watch(newsRepositoryProvider);
  final savedIds = await ref
      .watch(savedStoriesRepositoryProvider)
      .getSavedStoryIds();
  final stories = await repository.getPositiveStories();
  return stories
      .map((story) => story.copyWith(isSaved: savedIds.contains(story.id)))
      .toList();
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

final savedSnapshotsProvider = StreamProvider<List<SavedStorySnapshot>>((ref) {
  return ref.watch(savedStoriesRepositoryProvider).watchSavedStories();
});
