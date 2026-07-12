import '../../../shared/models/news_models.dart';
import '../domain/story_question_service.dart';

class MockStoryQuestionService implements StoryQuestionService {
  @override
  Future<AiStoryAnswer> askQuestion(StoryCluster story, String question) async {
    final text = question.toLowerCase();
    if (story.verificationStatus == VerificationStatus.insufficientEvidence ||
        text.contains('prove') ||
        text.contains('certain')) {
      return AiStoryAnswer(
        answer:
            'VeriMundi does not currently have enough reliable source material to answer that with confidence.',
        insufficientEvidence: true,
        confidenceScore: 0.18,
        sourceIds: const [],
        generatedAt: DateTime.now(),
      );
    }
    return AiStoryAnswer(
      answer:
          'Based only on the listed demo sources, the key point is: ${story.whyItMatters} The answer is grounded in the source IDs shown below.',
      insufficientEvidence: false,
      confidenceScore: story.confidenceScore,
      sourceIds: story.sourceArticles
          .take(2)
          .map((source) => source.id)
          .toList(),
      generatedAt: DateTime.now(),
    );
  }
}
