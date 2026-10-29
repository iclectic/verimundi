import '../../../shared/models/news_models.dart';

/// Ask VeriMundi + problem reports without binding UI to a concrete repository.
abstract interface class StoryInteractionPort {
  /// True when Ask/report hit the live API (false for local demo mode).
  bool get submitsRemotely;

  Future<void> reportStory(
    String storyId, {
    required String reason,
    String? details,
  });

  Future<AiStoryAnswer> askQuestion(String storyId, String question);
}
