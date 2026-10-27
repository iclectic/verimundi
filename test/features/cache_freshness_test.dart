import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verimundi/core/cache/cache_freshness.dart';
import 'package:verimundi/core/database/app_database.dart';
import 'package:verimundi/features/stories/data/feed_cache_repository.dart';
import 'package:verimundi/shared/widgets/cache_status_banner.dart';

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

  test('offline labels never present cache as live', () {
    const policy = CachePolicy();
    final now = DateTime(2026, 10, 24, 12);

    final fresh = policy.offlineLabel(
      now.subtract(const Duration(minutes: 2)),
      now: now,
    );
    final stale = policy.offlineLabel(
      now.subtract(const Duration(hours: 2)),
      now: now,
    );
    final expired = policy.offlineLabel(
      now.subtract(const Duration(hours: 10)),
      now: now,
    );

    expect(fresh.toLowerCase(), contains('offline'));
    expect(fresh.toLowerCase(), contains('not a live'));
    expect(stale.toLowerCase(), contains('not live'));
    expect(expired.toLowerCase(), contains('expired'));
    expect(expired.toLowerCase(), contains('not a live feed'));
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
      total: 42,
      page: 2,
      pageSize: 20,
    );
    final loaded = await cache.readStories('stories:test');
    expect(loaded, isNotNull);
    expect(loaded!.stories.single.id, 'cache-1');
    expect(loaded.stories.single.shortSummary, isNotEmpty);
    expect(loaded.total, 42);
    expect(loaded.page, 2);
    expect(loaded.pageSize, 20);
    expect(loaded.label.toLowerCase(), contains('offline'));
  });

  test('expired cache is served offline with expired freshness', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final cache = FeedCacheRepository(
      database,
      policy: const CachePolicy(
        freshFor: Duration(minutes: 1),
        usableFor: Duration(minutes: 2),
      ),
    );
    final story = storyFixture(id: 'expired-1');
    await cache.saveStories(
      cacheKey: 'stories:expired',
      stories: [story],
      sourceMode: 'remote',
      total: 7,
    );

    final row = await database.feedCache('stories:expired');
    expect(row, isNotNull);
    await database.upsertFeedCache(
      row!
          .toCompanion(true)
          .copyWith(
            fetchedAt: Value(
              DateTime.now().toUtc().subtract(const Duration(hours: 1)),
            ),
          ),
    );

    final loaded = await cache.readStories('stories:expired');
    expect(loaded, isNotNull);
    expect(loaded!.freshness, CacheFreshness.expired);
    expect(loaded.total, 7);
    expect(loaded.label.toLowerCase(), contains('expired'));
    expect(loaded.label.toLowerCase(), contains('not a live feed'));

    final rejected = await cache.readStories(
      'stories:expired',
      allowExpired: false,
    );
    expect(rejected, isNull);
  });

  test('legacy list payload still reads with story-count total', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final cache = FeedCacheRepository(database);
    final story = storyFixture(id: 'legacy-1');
    await database.upsertFeedCache(
      CachedFeedEntriesCompanion.insert(
        cacheKey: 'stories:legacy',
        payloadJson: jsonEncode([story.toJson()]),
        fetchedAt: DateTime.now().toUtc(),
        sourceMode: const Value('mock'),
      ),
    );

    final loaded = await cache.readStories('stories:legacy');
    expect(loaded, isNotNull);
    expect(loaded!.stories.single.id, 'legacy-1');
    expect(loaded.total, 1);
    expect(loaded.page, isNull);
  });

  testWidgets('cache banner stays visible for fresh offline snapshots', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CacheStatusBanner(
            label:
                'Offline — showing cached copy from moments ago (not a live feed)',
            freshness: CacheFreshness.fresh,
          ),
        ),
      ),
    );

    expect(find.textContaining('Offline'), findsOneWidget);
    expect(find.textContaining('not a live feed'), findsOneWidget);
  });

  testWidgets('expired banner uses strong offline copy', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CacheStatusBanner(
            label:
                'Offline — expired snapshot from 8 hours ago. May be out of date. Not a live feed.',
            freshness: CacheFreshness.expired,
          ),
        ),
      ),
    );

    expect(find.textContaining('expired snapshot'), findsOneWidget);
    expect(find.byIcon(Icons.wifi_off_outlined), findsOneWidget);
  });
}
