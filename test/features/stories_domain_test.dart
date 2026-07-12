import 'package:flutter_test/flutter_test.dart';
import 'package:verimundi/core/utils/date_formatters.dart';
import 'package:verimundi/features/stories/data/enum_parsing.dart';
import 'package:verimundi/features/stories/data/story_filtering.dart';
import 'package:verimundi/features/stories/data/underreported_scoring_service.dart';
import 'package:verimundi/shared/models/news_models.dart';

import '../test_helpers.dart';

void main() {
  test('underreported score rewards importance, local coverage, and international gap', () {
    const service = UnderreportedScoringService();
    final high = service.calculate(
      severity: Severity.critical,
      localSourceCount: 6,
      regionalSourceCount: 2,
      internationalSourceCount: 0,
    );
    final low = service.calculate(
      severity: Severity.general,
      localSourceCount: 1,
      regionalSourceCount: 0,
      internationalSourceCount: 6,
    );
    expect(high, greaterThan(low));
    expect(high, inInclusiveRange(0, 100));
  });

  test('severity and tone parsing fall back safely', () {
    expect(parseSeverity('critical'), Severity.critical);
    expect(parseSeverity('unexpected'), Severity.general);
    expect(parseTone('positive'), Tone.positive);
    expect(parseTone('unexpected'), Tone.neutral);
  });

  test('story filtering searches and applies structured filters', () {
    const filtering = StoryFiltering();
    final stories = [
      storyFixture(id: 'a', headline: 'Mobile clinics expand', tone: Tone.positive),
      storyFixture(id: 'b', headline: 'Water advisory', region: 'Europe', severity: Severity.serious),
    ];
    final result = filtering.apply(
      stories,
      const StoryFilter(query: 'clinic', region: 'Africa', tone: Tone.positive),
    );
    expect(result.map((story) => story.id), ['a']);
  });

  test('date formatter returns compact relative values', () {
    final now = DateTime.utc(2026, 7, 12, 12);
    expect(DateFormatters.relative(now.subtract(const Duration(hours: 2)), now: now), '2h ago');
  });
}
