import '../../../shared/models/news_models.dart';
import 'story_interaction_port.dart';
import 'story_page_result.dart';

/// Feed + country reads, plus Ask/report via [StoryInteractionPort].
abstract interface class NewsRepository implements StoryInteractionPort {
  /// World Pulse / discovery page. Remote uses `/v1/search` when [StoryFilter.query]
  /// is set, otherwise `/v1/stories`.
  Future<StoryPageResult> getStories(StoryFilter filter);
  Future<StoryCluster?> getStoryById(String id);
  Future<List<CountryNewsStatus>> getCountryStatuses();
  Future<List<StoryCluster>> getUnderreportedStories();
  Future<List<StoryCluster>> getPositiveStories();
}

abstract interface class GenAiSummaryService {
  Future<StoryCluster> refreshSummary(StoryCluster story);
}
