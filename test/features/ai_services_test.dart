import 'package:flutter_test/flutter_test.dart';
import 'package:verimundi/features/stories/data/mock_news_repository.dart';
import 'package:verimundi/features/story_questions/data/mock_story_question_service.dart';
import 'package:verimundi/shared/models/news_models.dart';

import '../test_helpers.dart';

void main() {
  test('mock AI summary handles insufficient evidence transparently', () async {
    final service = MockGenAiSummaryService();
    final story = storyFixture(
      verificationStatus: VerificationStatus.insufficientEvidence,
    );
    final result = await service.refreshSummary(story);

    expect(result.confidenceScore, 0);
    expect(
      result.shortSummary,
      contains('not currently have enough reliable source material'),
    );
  });

  test(
    'mock question service returns insufficient evidence for certainty prompts',
    () async {
      final service = MockStoryQuestionService();
      final answer = await service.askQuestion(
        storyFixture(),
        'Can you prove this is certain?',
      );

      expect(answer.insufficientEvidence, isTrue);
      expect(answer.sourceIds, isEmpty);
    },
  );
}
