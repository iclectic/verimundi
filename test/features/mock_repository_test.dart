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
      final page = await repository.getStories(const StoryFilter());

      expect(countries, hasLength(20));
      expect(page.stories, hasLength(20));
      expect(page.total, 30);
      expect(page.hasMore, isTrue);
      expect(page.stories.every((story) => story.isDemoContent), isTrue);
      expect(
        page.stories.every((story) => story.sourceArticles.isNotEmpty),
        isTrue,
      );
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
