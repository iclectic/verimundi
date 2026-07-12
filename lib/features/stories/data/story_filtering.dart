import '../../../shared/models/news_models.dart';

class StoryFiltering {
  const StoryFiltering();

  List<StoryCluster> apply(List<StoryCluster> stories, StoryFilter filter) {
    return stories.where((story) {
      final query = filter.query?.trim().toLowerCase();
      if (query != null && query.isNotEmpty) {
        final haystack = [
          story.headline,
          story.shortSummary,
          story.fullSummary,
          story.region,
          story.primaryCountryCode,
          story.category.name,
        ].join(' ').toLowerCase();
        if (!haystack.contains(query)) return false;
      }
      if (filter.region != null && story.region != filter.region) return false;
      if (filter.countryCode != null && !story.countryCodes.contains(filter.countryCode)) {
        return false;
      }
      if (filter.category != null && story.category != filter.category) return false;
      if (filter.severity != null && story.severity != filter.severity) return false;
      if (filter.tone != null && story.tone != filter.tone) return false;
      if (filter.verificationStatus != null &&
          story.verificationStatus != filter.verificationStatus) {
        return false;
      }
      if (filter.hasLocalCoverage == true && story.localSourceCount == 0) return false;
      if (filter.from != null && story.lastUpdatedAt.isBefore(filter.from!)) return false;
      if (filter.to != null && story.firstPublishedAt.isAfter(filter.to!)) return false;
      return true;
    }).toList();
  }
}
