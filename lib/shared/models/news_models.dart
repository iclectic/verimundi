import 'package:freezed_annotation/freezed_annotation.dart';

part 'news_models.freezed.dart';
part 'news_models.g.dart';

enum CredibilityStatus {
  established,
  specialist,
  community,
  unverified,
  unknown,
}

enum StoryCategory {
  politics,
  conflict,
  economy,
  climate,
  environment,
  science,
  technology,
  health,
  education,
  culture,
  humanRights,
  community,
  sport,
  other,
}

enum Severity { critical, serious, developing, general }

enum Tone { positive, neutral, concerning, mixed }

enum VerificationStatus {
  confirmed,
  developing,
  disputed,
  corrected,
  insufficientEvidence,
}

enum FeedMode { worldPulse, underreported, positiveWorld }

@freezed
abstract class Region with _$Region {
  const factory Region({
    required String id,
    required String name,
    required String displayName,
    required List<String> countryCodes,
  }) = _Region;

  factory Region.fromJson(Map<String, dynamic> json) => _$RegionFromJson(json);
}

@freezed
abstract class CountryNewsStatus with _$CountryNewsStatus {
  const factory CountryNewsStatus({
    required String code,
    required String name,
    required String region,
    required double latitude,
    required double longitude,
    required Severity currentSeverity,
    required int activeStoryCount,
    required int positiveStoryCount,
    required DateTime lastUpdated,
  }) = _CountryNewsStatus;

  factory CountryNewsStatus.fromJson(Map<String, dynamic> json) =>
      _$CountryNewsStatusFromJson(json);
}

@freezed
abstract class NewsSource with _$NewsSource {
  const factory NewsSource({
    required String id,
    required String name,
    required String articleUrl,
    required String publisherUrl,
    required String countryCode,
    required String languageCode,
    required String publicationType,
    required bool isLocalSource,
    required DateTime publishedAt,
    String? author,
    required CredibilityStatus credibilityStatus,
    required String headline,
    @Default('regional') String coverageLevel,
  }) = _NewsSource;

  factory NewsSource.fromJson(Map<String, dynamic> json) =>
      _$NewsSourceFromJson(json);
}

@freezed
abstract class ConfirmedFact with _$ConfirmedFact {
  const factory ConfirmedFact({
    required String text,
    required List<String> sourceIds,
  }) = _ConfirmedFact;

  factory ConfirmedFact.fromJson(Map<String, dynamic> json) =>
      _$ConfirmedFactFromJson(json);
}

@freezed
abstract class StoryCluster with _$StoryCluster {
  const StoryCluster._();

  const factory StoryCluster({
    required String id,
    required String headline,
    required String shortSummary,
    required String fullSummary,
    required String whyItMatters,
    required List<String> countryCodes,
    required String primaryCountryCode,
    required String region,
    required StoryCategory category,
    required double latitude,
    required double longitude,
    required DateTime firstPublishedAt,
    required DateTime lastUpdatedAt,
    required Severity severity,
    required String severityReason,
    required Tone tone,
    required VerificationStatus verificationStatus,
    required double confidenceScore,
    required int localSourceCount,
    required int regionalSourceCount,
    required int internationalSourceCount,
    required double underreportedScore,
    required double positiveImpactScore,
    required List<NewsSource> sourceArticles,
    required List<ConfirmedFact> confirmedFacts,
    required List<String> uncertainties,
    String? imageUrl,
    @Default(false) bool isSaved,
    required bool isDemoContent,
  }) = _StoryCluster;

  int get sourceCount =>
      localSourceCount + regionalSourceCount + internationalSourceCount;

  factory StoryCluster.fromJson(Map<String, dynamic> json) =>
      _$StoryClusterFromJson(json);
}

@freezed
abstract class StoryFilter with _$StoryFilter {
  const factory StoryFilter({
    String? query,
    String? region,
    String? countryCode,
    StoryCategory? category,
    Severity? severity,
    Tone? tone,
    VerificationStatus? verificationStatus,
    bool? hasLocalCoverage,
    DateTime? from,
    DateTime? to,
  }) = _StoryFilter;
}

@freezed
abstract class SavedStorySnapshot with _$SavedStorySnapshot {
  const factory SavedStorySnapshot({
    required String storyId,
    required DateTime savedAt,
    required String headlineSnapshot,
    required String country,
    required String summarySnapshot,
    required VerificationStatus verificationStatus,
    required int lastKnownSourceCount,
  }) = _SavedStorySnapshot;
}

@freezed
abstract class AiStoryAnswer with _$AiStoryAnswer {
  const factory AiStoryAnswer({
    required String answer,
    required bool insufficientEvidence,
    required double confidenceScore,
    required List<String> sourceIds,
    required DateTime generatedAt,
  }) = _AiStoryAnswer;
}
