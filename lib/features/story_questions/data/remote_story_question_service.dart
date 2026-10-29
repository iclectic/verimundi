import '../../stories/domain/story_interaction_port.dart';
import '../../../shared/models/news_models.dart';
import '../domain/story_question_service.dart';

/// Ask VeriMundi backed by [StoryInteractionPort] (remote or mock).
class PortStoryQuestionService implements StoryQuestionService {
  PortStoryQuestionService(this._port);

  final StoryInteractionPort _port;

  @override
  Future<AiStoryAnswer> askQuestion(StoryCluster story, String question) {
    return _port.askQuestion(story.id, question);
  }
}

/// Kept for older call sites / docs; prefer [PortStoryQuestionService].
typedef RemoteStoryQuestionService = PortStoryQuestionService;
