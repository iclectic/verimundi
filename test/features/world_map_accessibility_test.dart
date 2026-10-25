import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verimundi/features/world/presentation/world_map_view.dart';
import 'package:verimundi/shared/models/news_models.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('world map exposes list alternative and severity legend text', (
    tester,
  ) async {
    final countries = [
      CountryNewsStatus(
        code: 'NG',
        name: 'Nigeria',
        region: 'Africa',
        latitude: 9,
        longitude: 7,
        currentSeverity: Severity.serious,
        activeStoryCount: 2,
        positiveStoryCount: 1,
        lastUpdated: DateTime.now(),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: WorldMapView(
                countries: countries,
                stories: [storyFixture(id: 's1', country: 'NG')],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('critical'), findsWidgets);
    expect(find.text('Country list'), findsOneWidget);
    await tester.tap(find.text('Country list'));
    await tester.pumpAndSettle();
    expect(find.text('Nigeria'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('Accessible country list')),
      findsWidgets,
    );
  });
}
