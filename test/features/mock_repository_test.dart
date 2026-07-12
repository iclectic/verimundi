import 'package:flutter_test/flutter_test.dart';
import 'package:verimundi/features/stories/data/mock_news_repository.dart';
import 'package:verimundi/shared/models/news_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'mock repository exposes countries and story clusters from local catalog',
    () async {
      final repository = MockNewsRepository();
      final countries = await repository.getCountryStatuses();
      final stories = await repository.getStories(const StoryFilter());

      expect(countries, hasLength(20));
      expect(stories, hasLength(30));
      expect(stories.every((story) => story.isDemoContent), isTrue);
      expect(stories.every((story) => story.sourceArticles.isNotEmpty), isTrue);
    },
  );

  test('mock repository sorts underreported and positive feeds', () async {
    final repository = MockNewsRepository();
    final underreported = await repository.getUnderreportedStories();
    final positive = await repository.getPositiveStories();

    expect(
      underreported.first.underreportedScore,
      greaterThanOrEqualTo(underreported.last.underreportedScore),
    );
    expect(positive, isNotEmpty);
    expect(positive.every((story) => story.tone == Tone.positive), isTrue);
  });
}
