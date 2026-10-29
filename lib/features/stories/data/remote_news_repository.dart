import 'package:dio/dio.dart';

import '../../../core/constants/report_reasons.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/json_decoding.dart';
import '../../../core/network/remote_api_exception.dart';
import '../../../shared/models/news_models.dart';
import '../domain/news_repository.dart';
import '../domain/story_page_result.dart';
import 'enum_parsing.dart';

class RemoteNewsRepository implements NewsRepository {
  RemoteNewsRepository({required ApiClient client}) : _client = client;

  final ApiClient _client;

  Dio get _dio => _client.dio;

  @override
  bool get submitsRemotely => true;

  @override
  Future<StoryPageResult> getStories(StoryFilter filter) async {
    final hasQuery = filter.query != null && filter.query!.trim().isNotEmpty;
    // Phase 9: text discovery hits `/v1/search` (broader match). Browse uses `/v1/stories`.
    final path = hasQuery ? '/v1/search' : '/v1/stories';
    final response = await _get(
      path,
      query: hasQuery ? _searchQuery(filter) : _storyQuery(filter),
    );
    return parseStoryPage(response.data, filter);
  }

  @override
  Future<StoryCluster?> getStoryById(String id) async {
    try {
      final response = await _get('/v1/stories/$id');
      return parseStory(
        JsonDecoding.asObject(response.data, context: 'GET /v1/stories/{id}'),
      );
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
    if (response.data is! List) {
      throw const FormatException('Unexpected countries payload shape');
    }
    return JsonDecoding.asList(response.data)
        .map(
          (item) => _parseCountry(
            JsonDecoding.asObject(item, context: 'country item'),
          ),
        )
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

  @override
  Future<void> reportStory(
    String storyId, {
    required String reason,
    String? details,
  }) async {
    final trimmedReason = reason.trim();
    if (!ReportReasons.isAllowed(trimmedReason)) {
      throw const RemoteApiException(
        kind: RemoteApiErrorKind.badRequest,
        message: 'Reason must be one of the supported report categories.',
        code: 'invalid_reason',
        statusCode: 400,
      );
    }
    final trimmedDetails = details?.trim();
    if (trimmedDetails != null &&
        trimmedDetails.length > ReportReasons.maxDetailsLength) {
      throw const RemoteApiException(
        kind: RemoteApiErrorKind.badRequest,
        message: 'Details must be at most 500 characters.',
        code: 'invalid_details',
        statusCode: 400,
      );
    }

    try {
      await _dio.post<void>(
        '/v1/stories/$storyId/reports',
        data: {
          'reason': trimmedReason,
          if (trimmedDetails != null && trimmedDetails.isNotEmpty)
            'details': trimmedDetails,
        },
      );
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  @override
  Future<AiStoryAnswer> askQuestion(String storyId, String question) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty || trimmed.length > 500) {
      throw const RemoteApiException(
        kind: RemoteApiErrorKind.badRequest,
        message: 'Question must be between 1 and 500 characters.',
        code: 'invalid_question',
        statusCode: 400,
      );
    }

    try {
      // GenAI Ask can be slower than feed GETs — allow up to backend Ai:TimeoutSeconds.
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/stories/$storyId/questions',
        data: {'question': trimmed},
        options: Options(
          sendTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 45),
        ),
      );
      final data = response.data;
      if (data == null) {
        throw const FormatException('Ask VeriMundi returned an empty body');
      }
      return parseAiStoryAnswer(data);
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  /// Visible for unit tests — maps `/v1/.../questions` JSON (incl. uncertainty).
  static AiStoryAnswer parseAiStoryAnswer(Map<String, dynamic> data) {
    final hasConfidenceScore =
        data.containsKey('confidenceScore') && data['confidenceScore'] != null;
    final confidence = hasConfidenceScore
        ? JsonDecoding.asDouble(data['confidenceScore'])
        : JsonDecoding.asDouble(data['confidence']);
    return AiStoryAnswer(
      answer: JsonDecoding.asString(data['answer']),
      insufficientEvidence: JsonDecoding.asBool(data['insufficientEvidence']),
      confidenceScore: confidence,
      sourceIds: JsonDecoding.asStringList(data['sourceIds']),
      generatedAt: JsonDecoding.asDateTime(data['generatedAt']),
      uncertainty: JsonDecoding.asStringOrNull(data['uncertainty']),
    );
  }

  /// Visible for fixture / contract tests — maps paged `/v1/stories` / `/v1/search`.
  static StoryPageResult parseStoryPage(dynamic data, StoryFilter filter) {
    final page = filter.page < 1 ? 1 : filter.page;
    final pageSize = filter.pageSize.clamp(1, 100);
    final object = JsonDecoding.asObjectOrNull(data);
    if (object != null && object['items'] is List) {
      final stories = JsonDecoding.asList(object['items'])
          .map(
            (item) => parseStory(
              JsonDecoding.asObject(item, context: 'stories.items[]'),
            ),
          )
          .toList();
      final total = JsonDecoding.asInt(
        object['total'],
        fallback: stories.length,
      );
      return StoryPageResult(
        stories: stories,
        page: JsonDecoding.asInt(object['page'], fallback: page),
        pageSize: JsonDecoding.asInt(object['pageSize'], fallback: pageSize),
        total: total,
      );
    }
    if (data is List) {
      final stories = JsonDecoding.asList(data)
          .map(
            (item) =>
                parseStory(JsonDecoding.asObject(item, context: 'stories[]')),
          )
          .toList();
      return StoryPageResult(
        stories: stories,
        page: page,
        pageSize: pageSize,
        total: stories.length,
      );
    }
    throw const FormatException('Unexpected stories payload shape');
  }

  /// Visible for fixture / contract tests — maps a single `StoryDto`.
  static StoryCluster parseStory(Map<String, dynamic> json) {
    final sources = JsonDecoding.asList(json['sourceArticles'])
        .map(
          (item) => _parseSource(
            JsonDecoding.asObject(item, context: 'sourceArticles[]'),
          ),
        )
        .toList();
    final facts = JsonDecoding.asList(json['confirmedFacts']).map((item) {
      final map = JsonDecoding.asObject(item, context: 'confirmedFacts[]');
      return ConfirmedFact(
        text: JsonDecoding.asString(map['text']),
        sourceIds: JsonDecoding.asStringList(map['sourceIds']),
      );
    }).toList();
    final disputed = JsonDecoding.asList(json['disputedClaims']).map((item) {
      final map = JsonDecoding.asObject(item, context: 'disputedClaims[]');
      return DisputedClaim(
        text: JsonDecoding.asString(map['text']),
        supportingSourceIds: JsonDecoding.asStringList(
          map['supportingSourceIds'],
        ),
        disputingSourceIds: JsonDecoding.asStringList(
          map['disputingSourceIds'],
        ),
      );
    }).toList();

    return StoryCluster(
      id: JsonDecoding.asString(json['id']),
      headline: JsonDecoding.asString(json['headline']),
      shortSummary: JsonDecoding.asString(json['shortSummary']),
      fullSummary: JsonDecoding.asString(
        json['fullSummary'],
        fallback: JsonDecoding.asString(json['shortSummary']),
      ),
      whyItMatters: JsonDecoding.asString(json['whyItMatters']),
      countryCodes: JsonDecoding.asStringList(json['countryCodes']),
      primaryCountryCode: JsonDecoding.asString(json['primaryCountryCode']),
      region: JsonDecoding.asString(json['region']),
      category: _parseCategory(JsonDecoding.asStringOrNull(json['category'])),
      latitude: JsonDecoding.asDouble(json['latitude']),
      longitude: JsonDecoding.asDouble(json['longitude']),
      firstPublishedAt: JsonDecoding.asDateTime(
        json['firstPublishedAt'],
      ).toLocal(),
      lastUpdatedAt: JsonDecoding.asDateTime(json['lastUpdatedAt']).toLocal(),
      severity: parseSeverity(
        JsonDecoding.asString(json['severity'], fallback: 'general'),
      ),
      severityReason: JsonDecoding.asString(json['severityReason']),
      tone: parseTone(JsonDecoding.asString(json['tone'], fallback: 'neutral')),
      verificationStatus: _parseVerification(
        JsonDecoding.asStringOrNull(json['verificationStatus']),
      ),
      confidenceScore: JsonDecoding.asDouble(json['confidenceScore']),
      localSourceCount: JsonDecoding.asInt(json['localSourceCount']),
      regionalSourceCount: JsonDecoding.asInt(json['regionalSourceCount']),
      internationalSourceCount: JsonDecoding.asInt(
        json['internationalSourceCount'],
      ),
      independentSourceCount: JsonDecoding.asInt(
        json['independentSourceCount'],
      ),
      underreportedScore: JsonDecoding.asDouble(json['underreportedScore']),
      underreportedReason: JsonDecoding.asString(json['underreportedReason']),
      positiveImpactScore: JsonDecoding.asDouble(json['positiveImpactScore']),
      rankingReason: JsonDecoding.asString(json['rankingReason']),
      sourceArticles: sources,
      confirmedFacts: facts,
      disputedClaims: disputed,
      uncertainties: JsonDecoding.asStringList(json['uncertainties']),
      imageUrl: JsonDecoding.asStringOrNull(json['imageUrl']),
      isDemoContent: JsonDecoding.asBool(json['isDemoContent']),
      correctionNotice: JsonDecoding.asStringOrNull(json['correctionNotice']),
      correctedAt: JsonDecoding.asDateTimeOrNull(
        json['correctedAt'],
      )?.toLocal(),
    );
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
    final page = filter.page < 1 ? 1 : filter.page;
    final pageSize = filter.pageSize.clamp(1, 100);
    return {
      if (filter.region != null) 'region': filter.region,
      if (filter.countryCode != null) 'countryCode': filter.countryCode,
      if (filter.category != null) 'category': filter.category!.name,
      if (filter.severity != null) 'severity': filter.severity!.name,
      if (filter.tone != null) 'tone': filter.tone!.name,
      if (filter.verificationStatus != null)
        'verification': filter.verificationStatus!.name,
      if (filter.hasLocalCoverage == true) 'hasLocalCoverage': true,
      'page': page,
      'pageSize': pageSize,
    };
  }

  Map<String, dynamic> _searchQuery(StoryFilter filter) {
    final page = filter.page < 1 ? 1 : filter.page;
    final pageSize = filter.pageSize.clamp(1, 100);
    return {
      'q': filter.query!.trim(),
      if (filter.region != null) 'region': filter.region,
      if (filter.countryCode != null) 'countryCode': filter.countryCode,
      if (filter.category != null) 'category': filter.category!.name,
      if (filter.severity != null) 'severity': filter.severity!.name,
      if (filter.tone != null) 'tone': filter.tone!.name,
      if (filter.verificationStatus != null)
        'verification': filter.verificationStatus!.name,
      if (filter.hasLocalCoverage == true) 'hasLocalCoverage': true,
      'page': page,
      'pageSize': pageSize,
    };
  }

  List<StoryCluster> _parseStoryList(dynamic data) {
    return parseStoryPage(data, const StoryFilter()).stories;
  }

  static NewsSource _parseSource(Map<String, dynamic> json) {
    return NewsSource(
      id: JsonDecoding.asString(json['id']),
      name: JsonDecoding.asString(json['name']),
      articleUrl: JsonDecoding.asString(json['articleUrl']),
      publisherUrl: JsonDecoding.asString(json['publisherUrl']),
      countryCode: JsonDecoding.asString(json['countryCode']),
      languageCode: JsonDecoding.asString(json['languageCode'], fallback: 'en'),
      publicationType: JsonDecoding.asString(json['publicationType']),
      isLocalSource: JsonDecoding.asBool(json['isLocalSource']),
      publishedAt: JsonDecoding.asDateTime(json['publishedAt']).toLocal(),
      author: JsonDecoding.asStringOrNull(json['author']),
      credibilityStatus: CredibilityStatus.values.firstWhere(
        (item) => item.name == JsonDecoding.asString(json['credibilityStatus']),
        orElse: () => CredibilityStatus.unknown,
      ),
      headline: JsonDecoding.asString(json['headline']),
      coverageLevel: JsonDecoding.asString(
        json['coverageLevel'],
        fallback: 'regional',
      ),
    );
  }

  CountryNewsStatus _parseCountry(Map<String, dynamic> json) {
    return CountryNewsStatus(
      code: JsonDecoding.asString(json['code']),
      name: JsonDecoding.asString(json['name']),
      region: JsonDecoding.asString(json['region']),
      latitude: JsonDecoding.asDouble(json['latitude']),
      longitude: JsonDecoding.asDouble(json['longitude']),
      currentSeverity: parseSeverity(
        JsonDecoding.asString(json['currentSeverity'], fallback: 'general'),
      ),
      activeStoryCount: JsonDecoding.asInt(json['activeStoryCount']),
      positiveStoryCount: JsonDecoding.asInt(json['positiveStoryCount']),
      lastUpdated: JsonDecoding.asDateTime(json['lastUpdated']).toLocal(),
    );
  }

  static StoryCategory _parseCategory(String? value) {
    if (value == null || value.isEmpty) {
      return StoryCategory.other;
    }
    return StoryCategory.values.firstWhere(
      (item) => item.name.toLowerCase() == value.toLowerCase(),
      orElse: () => StoryCategory.other,
    );
  }

  static VerificationStatus _parseVerification(String? value) {
    if (value == null || value.isEmpty) {
      return VerificationStatus.developing;
    }
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
