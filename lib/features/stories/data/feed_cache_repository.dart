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
    required this.total,
    this.page,
    this.pageSize,
  });

  final List<StoryCluster> stories;
  final DateTime fetchedAt;
  final CacheFreshness freshness;

  /// Offline-safe label — never presents the snapshot as a live feed.
  final String label;
  final int total;
  final int? page;
  final int? pageSize;
}

class FeedCacheRepository {
  FeedCacheRepository(this._database, {this.policy = const CachePolicy()});

  final AppDatabase _database;
  final CachePolicy policy;

  Future<void> saveStories({
    required String cacheKey,
    required List<StoryCluster> stories,
    required String sourceMode,
    int? total,
    int? page,
    int? pageSize,
  }) {
    final envelope = <String, dynamic>{
      'v': 2,
      'stories': stories.map((s) => s.toJson()).toList(),
      'total': total ?? stories.length,
      'page': ?page,
      'pageSize': ?pageSize,
    };
    return _database.upsertFeedCache(
      CachedFeedEntriesCompanion.insert(
        cacheKey: cacheKey,
        payloadJson: jsonEncode(envelope),
        fetchedAt: DateTime.now().toUtc(),
        sourceMode: Value(sourceMode),
      ),
    );
  }

  /// Reads a feed snapshot for offline fallback.
  ///
  /// Expired entries are returned (not discarded) so the UI can show an
  /// explicit offline/expired warning instead of a hard failure. Pass
  /// [allowExpired]: false only when a caller must reject expired rows.
  Future<CachedFeedResult?> readStories(
    String cacheKey, {
    bool allowExpired = true,
  }) async {
    final row = await _database.feedCache(cacheKey);
    if (row == null) return null;
    final fetchedAt = row.fetchedAt.toLocal();
    final freshness = policy.evaluate(fetchedAt);
    if (freshness == CacheFreshness.expired && !allowExpired) {
      return null;
    }
    final decoded = _decodePayload(row.payloadJson);
    if (decoded == null) return null;
    return CachedFeedResult(
      stories: decoded.stories,
      fetchedAt: fetchedAt,
      freshness: freshness,
      label: policy.offlineLabel(fetchedAt),
      total: decoded.total,
      page: decoded.page,
      pageSize: decoded.pageSize,
    );
  }

  _DecodedFeedPayload? _decodePayload(String payloadJson) {
    final raw = jsonDecode(payloadJson);
    if (raw is List) {
      final stories = raw
          .map((item) => StoryCluster.fromJson(item as Map<String, dynamic>))
          .toList();
      return _DecodedFeedPayload(stories: stories, total: stories.length);
    }
    if (raw is Map<String, dynamic>) {
      final list = raw['stories'];
      if (list is! List) return null;
      final stories = list
          .map((item) => StoryCluster.fromJson(item as Map<String, dynamic>))
          .toList();
      final totalValue = raw['total'];
      final total = totalValue is int
          ? totalValue
          : totalValue is num
          ? totalValue.toInt()
          : stories.length;
      final pageValue = raw['page'];
      final pageSizeValue = raw['pageSize'];
      return _DecodedFeedPayload(
        stories: stories,
        total: total,
        page: pageValue is int
            ? pageValue
            : pageValue is num
            ? pageValue.toInt()
            : null,
        pageSize: pageSizeValue is int
            ? pageSizeValue
            : pageSizeValue is num
            ? pageSizeValue.toInt()
            : null,
      );
    }
    return null;
  }
}

class _DecodedFeedPayload {
  const _DecodedFeedPayload({
    required this.stories,
    required this.total,
    this.page,
    this.pageSize,
  });

  final List<StoryCluster> stories;
  final int total;
  final int? page;
  final int? pageSize;
}
