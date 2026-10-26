import 'news_models.dart';

extension StoryFilterConstraints on StoryFilter {
  /// True when any discovery constraint is set (search, region, chips, etc.).
  bool get hasActiveConstraints =>
      (query != null && query!.trim().isNotEmpty) ||
      region != null ||
      countryCode != null ||
      category != null ||
      severity != null ||
      tone != null ||
      verificationStatus != null ||
      hasLocalCoverage == true ||
      from != null ||
      to != null;
}
