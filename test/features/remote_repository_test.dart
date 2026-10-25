import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verimundi/core/network/api_client.dart';
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
    final stories = await repository.getStories(const StoryFilter());
    expect(stories, hasLength(1));
    expect(stories.first.headline, 'Test headline');
    expect(stories.first.independentSourceCount, 3);
    expect(stories.first.isDemoContent, isFalse);
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
