import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/stories/domain/story_interaction_port.dart';
import '../../features/story_questions/data/remote_story_question_service.dart';
import '../../features/story_questions/domain/story_question_service.dart';
import 'core_providers.dart';

/// Ask + report without UI casts to [RemoteNewsRepository].
final storyInteractionProvider = Provider<StoryInteractionPort>((ref) {
  return ref.watch(newsRepositoryProvider);
});

final storyQuestionServiceProvider = Provider<StoryQuestionService>((ref) {
  return PortStoryQuestionService(ref.watch(storyInteractionProvider));
});
