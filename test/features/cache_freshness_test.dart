import 'package:flutter_test/flutter_test.dart';
import 'package:verimundi/core/cache/cache_freshness.dart';
import 'package:verimundi/features/stories/data/feed_cache_repository.dart';
import 'package:verimundi/core/database/app_database.dart';
import 'package:drift/native.dart';

import '../test_helpers.dart';

void main() {
  test('cache policy classifies fresh, stale, and expired ages', () {
    const policy = CachePolicy(
      freshFor: Duration(minutes: 15),
      usableFor: Duration(hours: 6),
    );
    final now = DateTime(2026, 10, 24, 12);

    expect(
      policy.evaluate(now.subtract(const Duration(minutes: 5)), now: now),
      CacheFreshness.fresh,
    );
    expect(
      policy.evaluate(now.subtract(const Duration(hours: 2)), now: now),
      CacheFreshness.staleButUsable,
    );
    expect(
      policy.evaluate(now.subtract(const Duration(hours: 8)), now: now),
      CacheFreshness.expired,
    );
    expect(
      policy.label(now.subtract(const Duration(hours: 2)), now: now),
      contains('cached, still usable'),
    );
  });

  test('feed cache round-trips story metadata without bodies', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final cache = FeedCacheRepository(database);
    final story = storyFixture(id: 'cache-1');

    await cache.saveStories(
      cacheKey: 'stories:test',
      stories: [story],
      sourceMode: 'mock',
    );
    final loaded = await cache.readStories('stories:test');
    expect(loaded, isNotNull);
    expect(loaded!.stories.single.id, 'cache-1');
    expect(loaded.stories.single.shortSummary, isNotEmpty);
  });
}
