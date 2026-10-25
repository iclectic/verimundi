import '../../stories/data/remote_news_repository.dart';
import '../../../shared/models/news_models.dart';
import '../domain/story_question_service.dart';

class RemoteStoryQuestionService implements StoryQuestionService {
  RemoteStoryQuestionService(this._repository);

  final RemoteNewsRepository _repository;

  @override
  Future<AiStoryAnswer> askQuestion(StoryCluster story, String question) {
    return _repository.askQuestion(story.id, question);
  }
}
