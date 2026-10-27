import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verimundi/core/network/api_client.dart';
import 'package:verimundi/core/network/remote_api_exception.dart';
import 'package:verimundi/features/stories/data/remote_news_repository.dart';
import 'package:verimundi/shared/models/news_models.dart';

void main() {
  test('remote repository parses paged story payloads', () async {
    final dio = Dio()
      ..httpClientAdapter = _FakeAdapter({
        '/v1/stories': {
          'items': [
            {
              'id': '11111111-1111-1111-1111-111111111111',
              'headline': 'Test headline',
              'shortSummary': 'Summary',
              'fullSummary': 'Full',
              'whyItMatters': 'Matters',
              'countryCodes': ['NG'],
              'primaryCountryCode': 'NG',
              'region': 'Africa',
              'category': 'health',
              'latitude': 1.0,
              'longitude': 2.0,
              'firstPublishedAt': '2026-10-01T00:00:00Z',
              'lastUpdatedAt': '2026-10-02T00:00:00Z',
              'severity': 'developing',
              'severityReason': 'Emerging',
              'tone': 'neutral',
              'verificationStatus': 'developing',
              'confidenceScore': 0.6,
              'localSourceCount': 2,
              'regionalSourceCount': 1,
              'internationalSourceCount': 0,
              'independentSourceCount': 3,
              'underreportedScore': 70,
              'underreportedReason': 'Local coverage exceeds international.',
              'positiveImpactScore': 10,
              'rankingReason': 'Severity and recency.',
              'sourceArticles': <dynamic>[],
              'confirmedFacts': <dynamic>[],
              'disputedClaims': <dynamic>[],
              'uncertainties': ['Scale unclear'],
              'isDemoContent': false,
            },
          ],
          'page': 1,
          'pageSize': 20,
          'total': 1,
        },
      });

    final repository = RemoteNewsRepository(client: ApiClient(dio: dio));
    final page = await repository.getStories(const StoryFilter());
    expect(page.stories, hasLength(1));
    expect(page.total, 1);
    expect(page.stories.first.headline, 'Test headline');
    expect(page.stories.first.independentSourceCount, 3);
    expect(page.stories.first.isDemoContent, isFalse);
  });

  test(
    'remote repository maps maintenance responses to RemoteApiException',
    () async {
      final dio = Dio()
        ..httpClientAdapter = _StatusAdapter(
          statusCode: 503,
          body: {
            'code': 'maintenance',
            'message': 'VeriMundi is temporarily unavailable for maintenance.',
          },
        );

      final repository = RemoteNewsRepository(client: ApiClient(dio: dio));
      expect(
        () => repository.getStories(const StoryFilter()),
        throwsA(
          isA<RemoteApiException>().having(
            (e) => e.kind,
            'kind',
            RemoteApiErrorKind.maintenance,
          ),
        ),
      );
    },
  );

  test('remote repository sends page and pageSize query params', () async {
    final dio = Dio()
      ..httpClientAdapter = _CapturingAdapter({
        '/v1/stories': {
          'items': <dynamic>[],
          'page': 2,
          'pageSize': 10,
          'total': 0,
        },
      });

    final repository = RemoteNewsRepository(client: ApiClient(dio: dio));
    await repository.getStories(const StoryFilter(page: 2, pageSize: 10));
    final captured = dio.httpClientAdapter as _CapturingAdapter;
    expect(captured.lastPath, '/v1/stories');
    expect(captured.lastQuery?['page'], 2);
    expect(captured.lastQuery?['pageSize'], 10);
  });

  test('text query uses /v1/search with q and filters', () async {
    final dio = Dio()
      ..httpClientAdapter = _CapturingAdapter({
        '/v1/search': {
          'items': <dynamic>[],
          'page': 1,
          'pageSize': 20,
          'total': 0,
        },
      });

    final repository = RemoteNewsRepository(client: ApiClient(dio: dio));
    final result = await repository.getStories(
      const StoryFilter(
        query: 'clinic',
        region: 'Africa',
        severity: Severity.serious,
        hasLocalCoverage: true,
      ),
    );
    final captured = dio.httpClientAdapter as _CapturingAdapter;
    expect(captured.lastPath, '/v1/search');
    expect(captured.lastQuery?['q'], 'clinic');
    expect(captured.lastQuery?['region'], 'Africa');
    expect(captured.lastQuery?['severity'], 'serious');
    expect(captured.lastQuery?['hasLocalCoverage'], true);
    expect(result.total, 0);
    expect(result.hasMore, isFalse);
  });

  test('parseAiStoryAnswer reads confidence aliases and uncertainty', () {
    final answer = RemoteNewsRepository.parseAiStoryAnswer({
      'answer': 'Based on listed sources.',
      'insufficientEvidence': false,
      'confidence': 0.71,
      'sourceIds': ['src-a'],
      'uncertainty': 'Later developments may differ.',
      'generatedAt': '2026-10-27T10:00:00Z',
    });
    expect(answer.confidenceScore, 0.71);
    expect(answer.uncertainty, 'Later developments may differ.');
    expect(answer.sourceIds, ['src-a']);
  });

  test('askQuestion maps ask_rate_limited to RemoteApiException', () async {
    final dio = Dio()
      ..httpClientAdapter = _StatusAdapter(
        statusCode: 429,
        body: {
          'code': 'ask_rate_limited',
          'message': 'Too many Ask VeriMundi requests.',
        },
        headers: {'retry-after': '60'},
      );

    final repository = RemoteNewsRepository(client: ApiClient(dio: dio));
    expect(
      () => repository.askQuestion('11111111-1111-1111-1111-111111111111', 'Why?'),
      throwsA(
        isA<RemoteApiException>()
            .having((e) => e.kind, 'kind', RemoteApiErrorKind.rateLimited)
            .having((e) => e.code, 'code', 'ask_rate_limited'),
      ),
    );
  });

  test('askQuestion rejects empty questions client-side', () async {
    final repository = RemoteNewsRepository(client: ApiClient(dio: Dio()));
    expect(
      () => repository.askQuestion('id', '   '),
      throwsA(
        isA<RemoteApiException>().having(
          (e) => e.code,
          'code',
          'invalid_question',
        ),
      ),
    );
  });

  test('reportStory rejects unknown reasons client-side', () async {
    final repository = RemoteNewsRepository(client: ApiClient(dio: Dio()));
    expect(
      () => repository.reportStory('id', reason: 'spam'),
      throwsA(
        isA<RemoteApiException>().having(
          (e) => e.code,
          'code',
          'invalid_reason',
        ),
      ),
    );
  });

  test('reportStory maps report_rate_limited', () async {
    final dio = Dio()
      ..httpClientAdapter = _StatusAdapter(
        statusCode: 429,
        body: {
          'code': 'report_rate_limited',
          'message': 'Too many problem reports.',
        },
        headers: {'retry-after': '60'},
      );

    final repository = RemoteNewsRepository(client: ApiClient(dio: dio));
    expect(
      () => repository.reportStory(
        '11111111-1111-1111-1111-111111111111',
        reason: 'Other',
      ),
      throwsA(
        isA<RemoteApiException>()
            .having((e) => e.kind, 'kind', RemoteApiErrorKind.rateLimited)
            .having((e) => e.code, 'code', 'report_rate_limited'),
      ),
    );
  });
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.responses);

  final Map<String, dynamic> responses;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final payload = responses[options.path];
    if (payload == null) {
      return ResponseBody.fromString('not found', 404);
    }
    return ResponseBody.fromString(
      jsonEncode(payload),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

class _CapturingAdapter extends _FakeAdapter {
  _CapturingAdapter(super.responses);

  Map<String, dynamic>? lastQuery;
  String? lastPath;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) {
    lastPath = options.path;
    lastQuery = Map<String, dynamic>.from(options.queryParameters);
    return super.fetch(options, requestStream, cancelFuture);
  }
}

class _StatusAdapter implements HttpClientAdapter {
  _StatusAdapter({
    required this.statusCode,
    required this.body,
    this.headers = const {},
  });

  final int statusCode;
  final Map<String, dynamic> body;
  final Map<String, String> headers;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final responseHeaders = <String, List<String>>{
      Headers.contentTypeHeader: [Headers.jsonContentType],
      for (final entry in headers.entries) entry.key: [entry.value],
    };
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: responseHeaders,
    );
  }
}
