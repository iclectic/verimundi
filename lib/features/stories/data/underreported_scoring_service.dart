import '../../../shared/models/news_models.dart';

class UnderreportedScoringService {
  const UnderreportedScoringService();

  double calculate({
    required Severity severity,
    required int localSourceCount,
    required int regionalSourceCount,
    required int internationalSourceCount,
  }) {
    final importance = switch (severity) {
      Severity.critical => 1.0,
      Severity.serious => 0.78,
      Severity.developing => 0.58,
      Severity.general => 0.34,
    };
    final localCoverage = ((localSourceCount + regionalSourceCount) / 10).clamp(
      0.0,
      1.0,
    );
    final internationalGap = (1 - (internationalSourceCount / 6)).clamp(
      0.0,
      1.0,
    );
    return ((importance * 0.45 +
                localCoverage * 0.30 +
                internationalGap * 0.25) *
            100)
        .clamp(0, 100)
        .toDouble();
  }

  String explanation(StoryCluster story) {
    return 'Covered by ${story.localSourceCount + story.regionalSourceCount} local or regional sources and ${story.internationalSourceCount} international source${story.internationalSourceCount == 1 ? '' : 's'}. This provisional score is a discovery aid, not a judgement of objective importance.';
  }
}
