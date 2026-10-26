import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/remote_api_exception.dart';
import '../../../shared/models/news_models.dart';
import '../domain/news_repository.dart';
import 'enum_parsing.dart';
import 'story_filtering.dart';

class RemoteNewsRepository implements NewsRepository {
  RemoteNewsRepository({
    required ApiClient client,
    StoryFiltering filtering = const StoryFiltering(),
  }) : _client = client,
       _filtering = filtering;

  final ApiClient _client;
  final StoryFiltering _filtering;

  Dio get _dio => _client.dio;

  @override
  Future<List<StoryCluster>> getStories(StoryFilter filter) async {
    final response = await _get('/v1/stories', query: _storyQuery(filter));
    final stories = _parseStoryList(response.data);
    // Server already filters; apply local filter for parity with any client-only fields.
    return _filtering.apply(stories, filter);
  }

  @override
  Future<StoryCluster?> getStoryById(String id) async {
    try {
      final response = await _get('/v1/stories/$id');
      return _parseStory(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      throw _mapError(error);
    }
  }

  @override
  Future<List<CountryNewsStatus>> getCountryStatuses() async {
    final response = await _get('/v1/countries');
    final list = response.data as List<dynamic>;
    return list
        .map((item) => _parseCountry(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<StoryCluster>> getUnderreportedStories() async {
    final response = await _get('/v1/stories/underreported');
    return _parseStoryList(response.data);
  }

  @override
  Future<List<StoryCluster>> getPositiveStories() async {
    final response = await _get('/v1/stories/positive');
    return _parseStoryList(response.data);
  }

  Future<void> reportStory(
    String storyId, {
    required String reason,
    String? details,
  }) async {
    try {
      await _dio.post<void>(
        '/v1/stories/$storyId/reports',
        data: {
          'reason': reason,
          if (details != null && details.isNotEmpty) 'details': details,
        },
      );
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  Future<AiStoryAnswer> askQuestion(String storyId, String question) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/stories/$storyId/questions',
        data: {'question': question},
        options: Options(receiveTimeout: const Duration(seconds: 20)),
      );
      final data = response.data!;
      return AiStoryAnswer(
        answer: data['answer'] as String? ?? '',
        insufficientEvidence: data['insufficientEvidence'] as bool? ?? false,
        confidenceScore: (data['confidenceScore'] as num?)?.toDouble() ?? 0,
        sourceIds: (data['sourceIds'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        generatedAt:
            DateTime.tryParse(data['generatedAt'] as String? ?? '') ??
            DateTime.now().toUtc(),
      );
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  Future<Response<dynamic>> _get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      return await _dio.get<dynamic>(path, queryParameters: query);
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  Map<String, dynamic> _storyQuery(StoryFilter filter) {
    return {
      if (filter.query != null && filter.query!.trim().isNotEmpty)
        'query': filter.query!.trim(),
      if (filter.region != null) 'region': filter.region,
      if (filter.countryCode != null) 'countryCode': filter.countryCode,
      if (filter.category != null) 'category': filter.category!.name,
      if (filter.severity != null) 'severity': filter.severity!.name,
      if (filter.tone != null) 'tone': filter.tone!.name,
      if (filter.verificationStatus != null)
        'verification': filter.verificationStatus!.name,
      'page': 1,
      'pageSize': 100,
    };
  }

  List<StoryCluster> _parseStoryList(dynamic data) {
    if (data is Map<String, dynamic> && data['items'] is List) {
      return (data['items'] as List<dynamic>)
          .map((item) => _parseStory(item as Map<String, dynamic>))
          .toList();
    }
    if (data is List<dynamic>) {
      return data
          .map((item) => _parseStory(item as Map<String, dynamic>))
          .toList();
    }
    throw const FormatException('Unexpected stories payload shape');
  }

  StoryCluster _parseStory(Map<String, dynamic> json) {
    final sources = (json['sourceArticles'] as List<dynamic>? ?? const [])
        .map((item) => _parseSource(item as Map<String, dynamic>))
        .toList();
    final facts = (json['confirmedFacts'] as List<dynamic>? ?? const []).map((
      item,
    ) {
      final map = item as Map<String, dynamic>;
      return ConfirmedFact(
        text: map['text'] as String? ?? '',
        sourceIds: (map['sourceIds'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
      );
    }).toList();
    final disputed = (json['disputedClaims'] as List<dynamic>? ?? const []).map(
      (item) {
        final map = item as Map<String, dynamic>;
        return DisputedClaim(
          text: map['text'] as String? ?? '',
          supportingSourceIds:
              (map['supportingSourceIds'] as List<dynamic>? ?? const [])
                  .map((e) => e.toString())
                  .toList(),
          disputingSourceIds:
              (map['disputingSourceIds'] as List<dynamic>? ?? const [])
                  .map((e) => e.toString())
                  .toList(),
        );
      },
    ).toList();

    return StoryCluster(
      id: json['id'].toString(),
      headline: json['headline'] as String? ?? '',
      shortSummary: json['shortSummary'] as String? ?? '',
      fullSummary:
          json['fullSummary'] as String? ??
          json['shortSummary'] as String? ??
          '',
      whyItMatters: json['whyItMatters'] as String? ?? '',
      countryCodes: (json['countryCodes'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      primaryCountryCode: json['primaryCountryCode'] as String? ?? '',
      region: json['region'] as String? ?? '',
      category: _parseCategory(json['category'] as String?),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      firstPublishedAt: _parseDate(json['firstPublishedAt']),
      lastUpdatedAt: _parseDate(json['lastUpdatedAt']),
      severity: parseSeverity(json['severity'] as String? ?? 'general'),
      severityReason: json['severityReason'] as String? ?? '',
      tone: parseTone(json['tone'] as String? ?? 'neutral'),
      verificationStatus: _parseVerification(
        json['verificationStatus'] as String?,
      ),
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0,
      localSourceCount: json['localSourceCount'] as int? ?? 0,
      regionalSourceCount: json['regionalSourceCount'] as int? ?? 0,
      internationalSourceCount: json['internationalSourceCount'] as int? ?? 0,
      independentSourceCount: json['independentSourceCount'] as int? ?? 0,
      underreportedScore: (json['underreportedScore'] as num?)?.toDouble() ?? 0,
      underreportedReason: json['underreportedReason'] as String? ?? '',
      positiveImpactScore:
          (json['positiveImpactScore'] as num?)?.toDouble() ?? 0,
      rankingReason: json['rankingReason'] as String? ?? '',
      sourceArticles: sources,
      confirmedFacts: facts,
      disputedClaims: disputed,
      uncertainties: (json['uncertainties'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      imageUrl: json['imageUrl'] as String?,
      isDemoContent: json['isDemoContent'] as bool? ?? false,
      correctionNotice: json['correctionNotice'] as String?,
      correctedAt: json['correctedAt'] == null
          ? null
          : _parseDate(json['correctedAt']),
    );
  }

  NewsSource _parseSource(Map<String, dynamic> json) {
    return NewsSource(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      articleUrl: json['articleUrl'] as String? ?? '',
      publisherUrl: json['publisherUrl'] as String? ?? '',
      countryCode: json['countryCode'] as String? ?? '',
      languageCode: json['languageCode'] as String? ?? 'en',
      publicationType: json['publicationType'] as String? ?? '',
      isLocalSource: json['isLocalSource'] as bool? ?? false,
      publishedAt: _parseDate(json['publishedAt']),
      author: json['author'] as String?,
      credibilityStatus: CredibilityStatus.values.firstWhere(
        (item) => item.name == (json['credibilityStatus'] as String? ?? ''),
        orElse: () => CredibilityStatus.unknown,
      ),
      headline: json['headline'] as String? ?? '',
      coverageLevel: json['coverageLevel'] as String? ?? 'regional',
    );
  }

  CountryNewsStatus _parseCountry(Map<String, dynamic> json) {
    return CountryNewsStatus(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      region: json['region'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      currentSeverity: parseSeverity(
        json['currentSeverity'] as String? ?? 'general',
      ),
      activeStoryCount: json['activeStoryCount'] as int? ?? 0,
      positiveStoryCount: json['positiveStoryCount'] as int? ?? 0,
      lastUpdated: _parseDate(json['lastUpdated']),
    );
  }

  DateTime _parseDate(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
    }
    return DateTime.now();
  }

  StoryCategory _parseCategory(String? value) {
    if (value == null) return StoryCategory.other;
    return StoryCategory.values.firstWhere(
      (item) => item.name.toLowerCase() == value.toLowerCase(),
      orElse: () => StoryCategory.other,
    );
  }

  VerificationStatus _parseVerification(String? value) {
    if (value == null) return VerificationStatus.developing;
    return VerificationStatus.values.firstWhere(
      (item) => item.name.toLowerCase() == value.toLowerCase(),
      orElse: () => VerificationStatus.developing,
    );
  }

  RemoteApiException _mapError(DioException error) {
    return RemoteApiException.fromDio(
      error,
      baseUrlHint: _client.dio.options.baseUrl,
    );
  }
}
