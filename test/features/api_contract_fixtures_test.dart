import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:verimundi/core/network/app_remote_config.dart';
import 'package:verimundi/core/network/json_decoding.dart';
import 'package:verimundi/features/stories/data/remote_news_repository.dart';
import 'package:verimundi/shared/models/news_models.dart';

Map<String, dynamic> _loadFixture(String name) {
  final file = File('test/fixtures/v1/$name');
  expect(file.existsSync(), isTrue, reason: 'missing fixture ${file.path}');
  return JsonDecoding.asObject(
    jsonDecode(file.readAsStringSync()),
    context: name,
  );
}

void main() {
  group('v1 contract fixtures', () {
    test('stories page fixture parses via schema-checked helpers', () {
      final page = RemoteNewsRepository.parseStoryPage(
        _loadFixture('stories_page.json'),
        const StoryFilter(),
      );

      expect(page.total, 1);
      expect(page.page, 1);
      expect(page.pageSize, 20);
      expect(page.stories, hasLength(1));
      final story = page.stories.single;
      expect(story.headline, contains('Clinic coverage'));
      expect(story.independentSourceCount, 3);
      expect(story.sourceArticles, hasLength(1));
      expect(story.confirmedFacts.single.text, contains('weekend hours'));
      expect(story.uncertainties, isNotEmpty);
      expect(story.isDemoContent, isFalse);
    });

    test('stories page tolerates numeric totals encoded as doubles', () {
      final raw = Map<String, dynamic>.from(_loadFixture('stories_page.json'));
      raw['total'] = 1.0;
      raw['page'] = 1.0;
      raw['pageSize'] = 20.0;
      final items = List<dynamic>.from(raw['items'] as List);
      final story = Map<String, dynamic>.from(items.first as Map);
      story['confidenceScore'] = 0.62;
      story['localSourceCount'] = 2.0;
      items[0] = story;
      raw['items'] = items;

      final page = RemoteNewsRepository.parseStoryPage(
        raw,
        const StoryFilter(),
      );
      expect(page.total, 1);
      expect(page.pageSize, 20);
      expect(page.stories.single.localSourceCount, 2);
      expect(page.stories.single.confidenceScore, closeTo(0.62, 0.001));
    });

    test('Ask fixture parses confidenceScore and uncertainty', () {
      final answer = RemoteNewsRepository.parseAiStoryAnswer(
        _loadFixture('ask_response.json'),
      );
      expect(answer.answer, contains('weekend clinic hours'));
      expect(answer.insufficientEvidence, isFalse);
      expect(answer.confidenceScore, closeTo(0.71, 0.001));
      expect(answer.sourceIds, ['aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa']);
      expect(answer.uncertainty, 'Later developments may differ.');
    });

    test('app config fixture matches AppConfigDto wire shape', () {
      final config = AppRemoteConfig.fromJson(_loadFixture('app_config.json'));
      expect(config.environment, 'Testing');
      expect(config.maintenanceMode, isFalse);
      expect(config.minimumAppVersion, '1.0.0');
      expect(config.enableRss, isFalse);
      expect(config.enableGdelt, isFalse);
      expect(config.aiProvider, 'heuristic');
      expect(config.disclaimer, contains('original reporting'));
    });

    test('malformed story list item throws FormatException', () {
      expect(
        () => RemoteNewsRepository.parseStoryPage({
          'items': ['not-an-object'],
          'page': 1,
          'pageSize': 20,
          'total': 1,
        }, const StoryFilter()),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
