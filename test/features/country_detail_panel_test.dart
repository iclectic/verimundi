import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verimundi/features/world/presentation/country_detail_panel.dart';
import 'package:verimundi/shared/models/news_models.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('country detail panel shows severity text and filter action', (
    tester,
  ) async {
    final country = CountryNewsStatus(
      code: 'NG',
      name: 'Nigeria',
      region: 'Africa',
      latitude: 9,
      longitude: 7,
      currentSeverity: Severity.serious,
      activeStoryCount: 2,
      positiveStoryCount: 1,
      lastUpdated: DateTime.utc(2026, 10, 27, 12),
    );
    var filtered = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CountryDetailPanel(
            country: country,
            stories: [storyFixture(id: 's1', country: 'NG')],
            onFilterFeed: () => filtered = true,
          ),
        ),
      ),
    );

    expect(find.text('Nigeria'), findsOneWidget);
    expect(find.textContaining('Serious'), findsWidgets);
    expect(find.textContaining('2 active'), findsOneWidget);
    expect(find.text('Filter feed to Nigeria'), findsOneWidget);
    await tester.tap(find.text('Filter feed to Nigeria'));
    expect(filtered, isTrue);
  });
}
