import 'package:verimundi/shared/models/news_models.dart';

StoryCluster storyFixture({
  String id = 'fixture',
  String headline = 'Fixture headline',
  String country = 'GH',
  String region = 'Africa',
  StoryCategory category = StoryCategory.health,
  Severity severity = Severity.general,
  Tone tone = Tone.neutral,
  VerificationStatus verificationStatus = VerificationStatus.confirmed,
  int local = 2,
  int regional = 1,
  int international = 1,
}) {
  final now = DateTime.utc(2026, 7, 12, 12);
  final sources = List.generate(local + regional + international, (index) {
    return NewsSource(
      id: '$id-source-$index',
      name: 'Source $index',
      articleUrl: 'https://example.test/$id/$index',
      publisherUrl: 'https://example.test',
      countryCode: country,
      languageCode: 'en',
      publicationType: 'local newsroom',
      isLocalSource: index < local,
      publishedAt: now,
      credibilityStatus: CredibilityStatus.established,
      headline: headline,
      coverageLevel: index < local
          ? 'local'
          : index < local + regional
          ? 'regional'
          : 'international',
    );
  });
  return StoryCluster(
    id: id,
    headline: headline,
    shortSummary: 'Short summary about health access',
    fullSummary: 'Full summary',
    whyItMatters: 'It matters for public access.',
    countryCodes: [country],
    primaryCountryCode: country,
    region: region,
    category: category,
    latitude: 0,
    longitude: 0,
    firstPublishedAt: now.subtract(const Duration(days: 1)),
    lastUpdatedAt: now,
    severity: severity,
    severityReason: 'Human readable reason',
    tone: tone,
    verificationStatus: verificationStatus,
    confidenceScore:
        verificationStatus == VerificationStatus.insufficientEvidence
        ? 0.1
        : 0.8,
    localSourceCount: local,
    regionalSourceCount: regional,
    internationalSourceCount: international,
    underreportedScore: 50,
    positiveImpactScore: tone == Tone.positive ? 80 : 10,
    sourceArticles: sources,
    confirmedFacts: [
      ConfirmedFact(
        text: 'A fact is confirmed.',
        sourceIds: [sources.first.id],
      ),
    ],
    uncertainties: const ['A detail remains uncertain.'],
    isDemoContent: true,
  );
}
