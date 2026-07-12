import '../../../shared/models/news_models.dart';

abstract interface class StoryQuestionService {
  Future<AiStoryAnswer> askQuestion(StoryCluster story, String question);
}
