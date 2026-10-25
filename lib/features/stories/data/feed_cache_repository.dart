import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/cache/cache_freshness.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/models/news_models.dart';

class CachedFeedResult {
  const CachedFeedResult({
    required this.stories,
    required this.fetchedAt,
    required this.freshness,
    required this.label,
  });

  final List<StoryCluster> stories;
  final DateTime fetchedAt;
  final CacheFreshness freshness;
  final String label;
}

class FeedCacheRepository {
  FeedCacheRepository(this._database, {this.policy = const CachePolicy()});

  final AppDatabase _database;
  final CachePolicy policy;

  Future<void> saveStories({
    required String cacheKey,
    required List<StoryCluster> stories,
    required String sourceMode,
  }) {
    final payload = jsonEncode(stories.map((s) => s.toJson()).toList());
    return _database.upsertFeedCache(
      CachedFeedEntriesCompanion.insert(
        cacheKey: cacheKey,
        payloadJson: payload,
        fetchedAt: DateTime.now().toUtc(),
        sourceMode: Value(sourceMode),
      ),
    );
  }

  Future<CachedFeedResult?> readStories(String cacheKey) async {
    final row = await _database.feedCache(cacheKey);
    if (row == null) return null;
    final freshness = policy.evaluate(row.fetchedAt.toLocal());
    if (freshness == CacheFreshness.expired) {
      return null;
    }
    final decoded = jsonDecode(row.payloadJson) as List<dynamic>;
    final stories = decoded
        .map((item) => StoryCluster.fromJson(item as Map<String, dynamic>))
        .toList();
    return CachedFeedResult(
      stories: stories,
      fetchedAt: row.fetchedAt.toLocal(),
      freshness: freshness,
      label: policy.label(row.fetchedAt.toLocal()),
    );
  }
}
