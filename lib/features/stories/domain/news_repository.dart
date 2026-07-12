import '../../../shared/models/news_models.dart';

abstract interface class NewsRepository {
  Future<List<StoryCluster>> getStories(StoryFilter filter);
  Future<StoryCluster?> getStoryById(String id);
  Future<List<CountryNewsStatus>> getCountryStatuses();
  Future<List<StoryCluster>> getUnderreportedStories();
  Future<List<StoryCluster>> getPositiveStories();
}

abstract interface class GenAiSummaryService {
  Future<StoryCluster> refreshSummary(StoryCluster story);
}
