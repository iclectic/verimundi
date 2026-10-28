import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verimundi/core/database/app_database.dart';
import 'package:verimundi/core/network/remote_api_exception.dart';
import 'package:verimundi/features/stories/data/feed_cache_repository.dart';
import 'package:verimundi/features/stories/data/mock_news_repository.dart';
import 'package:verimundi/features/stories/domain/news_repository.dart';
import 'package:verimundi/features/stories/domain/story_page_result.dart';
import 'package:verimundi/shared/models/news_models.dart';
import 'package:verimundi/shared/providers/app_providers.dart';

import '../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late FeedCacheRepository cache;
  late ProviderContainer container;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    cache = FeedCacheRepository(database);
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  test(
    'storiesFeedProvider falls back to cache on RemoteApiException only',
    () async {
      final story = storyFixture(id: 'offline-1');
      await cache.saveStories(
        cacheKey: FeedCacheKeys.stories(
          usedSearch: false,
          page: 1,
          filter: const StoryFilter(),
        ),
        stories: [story],
        sourceMode: FeedCacheKeys.sourceMode,
        total: 1,
        page: 1,
        pageSize: 20,
      );

      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(database),
          newsRepositoryProvider.overrideWithValue(
            _ScriptedNewsRepository(
              storiesError: const RemoteApiException(
                kind: RemoteApiErrorKind.offline,
                message: 'Unable to reach the VeriMundi API.',
                code: 'offline',
              ),
            ),
          ),
        ],
      );

      final feed = await container.read(storiesFeedProvider.future);
      expect(feed.fromCache, isTrue);
      expect(feed.stories.single.id, 'offline-1');
      expect(feed.cacheLabel.toLowerCase(), contains('offline'));
    },
  );

  test(
    'storiesFeedProvider does not swallow programming errors as offline cache',
    () async {
      final story = storyFixture(id: 'bug-1');
      await cache.saveStories(
        cacheKey: FeedCacheKeys.stories(
          usedSearch: false,
          page: 1,
          filter: const StoryFilter(),
        ),
        stories: [story],
        sourceMode: FeedCacheKeys.sourceMode,
        total: 1,
        page: 1,
        pageSize: 20,
      );

      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(database),
          newsRepositoryProvider.overrideWithValue(
            _ScriptedNewsRepository(
              storiesError: StateError('intentional provider bug'),
            ),
          ),
        ],
      );

      await expectLater(
        container.read(storiesFeedProvider.future),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'intentional provider bug',
          ),
        ),
      );
    },
  );

  test(
    'storyInteractionProvider exposes Ask/report without remote casts',
    () async {
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(database),
          newsRepositoryProvider.overrideWithValue(MockNewsRepository()),
        ],
      );

      final interaction = container.read(storyInteractionProvider);
      expect(interaction.submitsRemotely, isFalse);
      await interaction.reportStory('any', reason: 'Other');
      // Mock catalogue may not include 'any'; insufficient-evidence path is fine.
      final answer = await interaction.askQuestion('any', 'What happened?');
      expect(answer.insufficientEvidence, isTrue);
    },
  );

  test('curated lists share FeedCacheKeys helpers', () {
    const filter = StoryFilter(query: 'clinic', region: 'Africa');
    expect(
      FeedCacheKeys.underreported(filter),
      startsWith('underreported:${FeedCacheKeys.sourceMode}:'),
    );
    expect(FeedCacheKeys.positive, 'positive:${FeedCacheKeys.sourceMode}');
    expect(
      FeedCacheKeys.stories(usedSearch: true, page: 2, filter: filter),
      contains(':search:2:'),
    );
  });
}

/// Minimal [NewsRepository] that can throw scripted errors for catch hygiene.
class _ScriptedNewsRepository implements NewsRepository {
  _ScriptedNewsRepository({required this.storiesError});

  final Object storiesError;

  @override
  bool get submitsRemotely => true;

  @override
  Future<StoryPageResult> getStories(StoryFilter filter) async {
    throw storiesError;
  }

  @override
  Future<StoryCluster?> getStoryById(String id) async => null;

  @override
  Future<List<CountryNewsStatus>> getCountryStatuses() async => const [];

  @override
  Future<List<StoryCluster>> getUnderreportedStories() async => const [];

  @override
  Future<List<StoryCluster>> getPositiveStories() async => const [];

  @override
  Future<void> reportStory(
    String storyId, {
    required String reason,
    String? details,
  }) async {}

  @override
  Future<AiStoryAnswer> askQuestion(String storyId, String question) async {
    throw UnimplementedError();
  }
}
