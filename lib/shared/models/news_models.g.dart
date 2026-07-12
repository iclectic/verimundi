// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Region _$RegionFromJson(Map<String, dynamic> json) => _Region(
  id: json['id'] as String,
  name: json['name'] as String,
  displayName: json['displayName'] as String,
  countryCodes: (json['countryCodes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$RegionToJson(_Region instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'displayName': instance.displayName,
  'countryCodes': instance.countryCodes,
};

_CountryNewsStatus _$CountryNewsStatusFromJson(Map<String, dynamic> json) =>
    _CountryNewsStatus(
      code: json['code'] as String,
      name: json['name'] as String,
      region: json['region'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      currentSeverity: $enumDecode(_$SeverityEnumMap, json['currentSeverity']),
      activeStoryCount: (json['activeStoryCount'] as num).toInt(),
      positiveStoryCount: (json['positiveStoryCount'] as num).toInt(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$CountryNewsStatusToJson(_CountryNewsStatus instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'region': instance.region,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'currentSeverity': _$SeverityEnumMap[instance.currentSeverity]!,
      'activeStoryCount': instance.activeStoryCount,
      'positiveStoryCount': instance.positiveStoryCount,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

const _$SeverityEnumMap = {
  Severity.critical: 'critical',
  Severity.serious: 'serious',
  Severity.developing: 'developing',
  Severity.general: 'general',
};

_NewsSource _$NewsSourceFromJson(Map<String, dynamic> json) => _NewsSource(
  id: json['id'] as String,
  name: json['name'] as String,
  articleUrl: json['articleUrl'] as String,
  publisherUrl: json['publisherUrl'] as String,
  countryCode: json['countryCode'] as String,
  languageCode: json['languageCode'] as String,
  publicationType: json['publicationType'] as String,
  isLocalSource: json['isLocalSource'] as bool,
  publishedAt: DateTime.parse(json['publishedAt'] as String),
  author: json['author'] as String?,
  credibilityStatus: $enumDecode(
    _$CredibilityStatusEnumMap,
    json['credibilityStatus'],
  ),
  headline: json['headline'] as String,
  coverageLevel: json['coverageLevel'] as String? ?? 'regional',
);

Map<String, dynamic> _$NewsSourceToJson(
  _NewsSource instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'articleUrl': instance.articleUrl,
  'publisherUrl': instance.publisherUrl,
  'countryCode': instance.countryCode,
  'languageCode': instance.languageCode,
  'publicationType': instance.publicationType,
  'isLocalSource': instance.isLocalSource,
  'publishedAt': instance.publishedAt.toIso8601String(),
  'author': instance.author,
  'credibilityStatus': _$CredibilityStatusEnumMap[instance.credibilityStatus]!,
  'headline': instance.headline,
  'coverageLevel': instance.coverageLevel,
};

const _$CredibilityStatusEnumMap = {
  CredibilityStatus.established: 'established',
  CredibilityStatus.specialist: 'specialist',
  CredibilityStatus.community: 'community',
  CredibilityStatus.unverified: 'unverified',
  CredibilityStatus.unknown: 'unknown',
};

_ConfirmedFact _$ConfirmedFactFromJson(Map<String, dynamic> json) =>
    _ConfirmedFact(
      text: json['text'] as String,
      sourceIds: (json['sourceIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ConfirmedFactToJson(_ConfirmedFact instance) =>
    <String, dynamic>{'text': instance.text, 'sourceIds': instance.sourceIds};

_StoryCluster _$StoryClusterFromJson(Map<String, dynamic> json) =>
    _StoryCluster(
      id: json['id'] as String,
      headline: json['headline'] as String,
      shortSummary: json['shortSummary'] as String,
      fullSummary: json['fullSummary'] as String,
      whyItMatters: json['whyItMatters'] as String,
      countryCodes: (json['countryCodes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      primaryCountryCode: json['primaryCountryCode'] as String,
      region: json['region'] as String,
      category: $enumDecode(_$StoryCategoryEnumMap, json['category']),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      firstPublishedAt: DateTime.parse(json['firstPublishedAt'] as String),
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt'] as String),
      severity: $enumDecode(_$SeverityEnumMap, json['severity']),
      severityReason: json['severityReason'] as String,
      tone: $enumDecode(_$ToneEnumMap, json['tone']),
      verificationStatus: $enumDecode(
        _$VerificationStatusEnumMap,
        json['verificationStatus'],
      ),
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      localSourceCount: (json['localSourceCount'] as num).toInt(),
      regionalSourceCount: (json['regionalSourceCount'] as num).toInt(),
      internationalSourceCount: (json['internationalSourceCount'] as num)
          .toInt(),
      underreportedScore: (json['underreportedScore'] as num).toDouble(),
      positiveImpactScore: (json['positiveImpactScore'] as num).toDouble(),
      sourceArticles: (json['sourceArticles'] as List<dynamic>)
          .map((e) => NewsSource.fromJson(e as Map<String, dynamic>))
          .toList(),
      confirmedFacts: (json['confirmedFacts'] as List<dynamic>)
          .map((e) => ConfirmedFact.fromJson(e as Map<String, dynamic>))
          .toList(),
      uncertainties: (json['uncertainties'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      imageUrl: json['imageUrl'] as String?,
      isSaved: json['isSaved'] as bool? ?? false,
      isDemoContent: json['isDemoContent'] as bool,
    );

Map<String, dynamic> _$StoryClusterToJson(_StoryCluster instance) =>
    <String, dynamic>{
      'id': instance.id,
      'headline': instance.headline,
      'shortSummary': instance.shortSummary,
      'fullSummary': instance.fullSummary,
      'whyItMatters': instance.whyItMatters,
      'countryCodes': instance.countryCodes,
      'primaryCountryCode': instance.primaryCountryCode,
      'region': instance.region,
      'category': _$StoryCategoryEnumMap[instance.category]!,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'firstPublishedAt': instance.firstPublishedAt.toIso8601String(),
      'lastUpdatedAt': instance.lastUpdatedAt.toIso8601String(),
      'severity': _$SeverityEnumMap[instance.severity]!,
      'severityReason': instance.severityReason,
      'tone': _$ToneEnumMap[instance.tone]!,
      'verificationStatus':
          _$VerificationStatusEnumMap[instance.verificationStatus]!,
      'confidenceScore': instance.confidenceScore,
      'localSourceCount': instance.localSourceCount,
      'regionalSourceCount': instance.regionalSourceCount,
      'internationalSourceCount': instance.internationalSourceCount,
      'underreportedScore': instance.underreportedScore,
      'positiveImpactScore': instance.positiveImpactScore,
      'sourceArticles': instance.sourceArticles,
      'confirmedFacts': instance.confirmedFacts,
      'uncertainties': instance.uncertainties,
      'imageUrl': instance.imageUrl,
      'isSaved': instance.isSaved,
      'isDemoContent': instance.isDemoContent,
    };

const _$StoryCategoryEnumMap = {
  StoryCategory.politics: 'politics',
  StoryCategory.conflict: 'conflict',
  StoryCategory.economy: 'economy',
  StoryCategory.climate: 'climate',
  StoryCategory.environment: 'environment',
  StoryCategory.science: 'science',
  StoryCategory.technology: 'technology',
  StoryCategory.health: 'health',
  StoryCategory.education: 'education',
  StoryCategory.culture: 'culture',
  StoryCategory.humanRights: 'humanRights',
  StoryCategory.community: 'community',
  StoryCategory.sport: 'sport',
  StoryCategory.other: 'other',
};

const _$ToneEnumMap = {
  Tone.positive: 'positive',
  Tone.neutral: 'neutral',
  Tone.concerning: 'concerning',
  Tone.mixed: 'mixed',
};

const _$VerificationStatusEnumMap = {
  VerificationStatus.confirmed: 'confirmed',
  VerificationStatus.developing: 'developing',
  VerificationStatus.disputed: 'disputed',
  VerificationStatus.corrected: 'corrected',
  VerificationStatus.insufficientEvidence: 'insufficientEvidence',
};
