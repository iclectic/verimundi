import '../../core/constants/app_constants.dart';
import '../models/news_models.dart';

/// Stable Drift cache keys shared by World Pulse and curated feed providers.
class FeedCacheKeys {
  const FeedCacheKeys._();

  static String get sourceMode => AppConstants.isMockApi ? 'mock' : 'remote';

  static String stories({
    required bool usedSearch,
    required int page,
    required StoryFilter filter,
  }) {
    return 'stories:$sourceMode:${usedSearch ? 'search' : 'browse'}:$page:'
        '${filter.pageSize}:${filter.query}:${filter.region}:'
        '${filter.countryCode}:${filter.category}:${filter.severity}:'
        '${filter.tone}:${filter.verificationStatus}:${filter.hasLocalCoverage}';
  }

  static String underreported(StoryFilter filter) {
    return 'underreported:$sourceMode:${filter.query}:${filter.region}:'
        '${filter.countryCode}:${filter.category}:${filter.severity}:'
        '${filter.tone}:${filter.verificationStatus}:${filter.hasLocalCoverage}';
  }

  static String get positive => 'positive:$sourceMode';
}
