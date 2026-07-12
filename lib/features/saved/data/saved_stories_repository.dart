import '../../../shared/models/news_models.dart';

abstract interface class SavedStoriesRepository {
  Stream<List<SavedStorySnapshot>> watchSavedStories();
  Future<Set<String>> getSavedStoryIds();
  Future<bool> isSaved(String storyId);
  Future<void> save(StoryCluster story);
  Future<void> remove(String storyId);
}
