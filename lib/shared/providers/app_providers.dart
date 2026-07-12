import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../core/database/app_database.dart';
import '../../core/network/api_client.dart';
import '../../features/saved/data/drift_saved_stories_repository.dart';
import '../../features/saved/data/saved_stories_repository.dart';
import '../../features/stories/data/mock_news_repository.dart';
import '../../features/stories/domain/news_repository.dart';
import '../../features/story_questions/data/mock_story_question_service.dart';
import '../../features/story_questions/domain/story_question_service.dart';
import '../models/news_models.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

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

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return client.isMockMode ? MockNewsRepository() : RemoteNewsRepository();
});

final savedStoriesRepositoryProvider = Provider<SavedStoriesRepository>((ref) {
  return DriftSavedStoriesRepository(ref.watch(databaseProvider));
});

final storyQuestionServiceProvider = Provider<StoryQuestionService>((ref) {
  return MockStoryQuestionService();
});

final storyFilterProvider = StateProvider<StoryFilter>((ref) => const StoryFilter());

final feedModeProvider = StateProvider<FeedMode>((ref) => FeedMode.worldPulse);

final storiesProvider = FutureProvider<List<StoryCluster>>((ref) async {
  final repository = ref.watch(newsRepositoryProvider);
  final savedIds = await ref.watch(savedStoriesRepositoryProvider).getSavedStoryIds();
  final filter = ref.watch(storyFilterProvider);
  final stories = await repository.getStories(filter);
  return stories
      .map((story) => story.copyWith(isSaved: savedIds.contains(story.id)))
      .toList();
});

final underreportedStoriesProvider = FutureProvider<List<StoryCluster>>((ref) async {
  final repository = ref.watch(newsRepositoryProvider);
  final savedIds = await ref.watch(savedStoriesRepositoryProvider).getSavedStoryIds();
  final stories = await repository.getUnderreportedStories();
  return stories
      .map((story) => story.copyWith(isSaved: savedIds.contains(story.id)))
      .toList();
});

final positiveStoriesProvider = FutureProvider<List<StoryCluster>>((ref) async {
  final repository = ref.watch(newsRepositoryProvider);
  final savedIds = await ref.watch(savedStoriesRepositoryProvider).getSavedStoryIds();
  final stories = await repository.getPositiveStories();
  return stories
      .map((story) => story.copyWith(isSaved: savedIds.contains(story.id)))
      .toList();
});

final countriesProvider = FutureProvider<List<CountryNewsStatus>>((ref) {
  return ref.watch(newsRepositoryProvider).getCountryStatuses();
});

final storyByIdProvider = FutureProvider.family<StoryCluster?, String>((ref, id) async {
  final story = await ref.watch(newsRepositoryProvider).getStoryById(id);
  if (story == null) return null;
  final saved = await ref.watch(savedStoriesRepositoryProvider).isSaved(id);
  return story.copyWith(isSaved: saved);
});

final savedSnapshotsProvider = StreamProvider<List<SavedStorySnapshot>>((ref) {
  return ref.watch(savedStoriesRepositoryProvider).watchSavedStories();
});
