import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verimundi/features/world/presentation/world_map_view.dart';
import 'package:verimundi/shared/models/news_models.dart';

import '../test_helpers.dart';

void main() {
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
    CountryNewsStatus(
      code: 'BB',
      name: 'Barbados',
      region: 'Latin America and the Caribbean',
      latitude: 13,
      longitude: -59,
      currentSeverity: Severity.general,
      activeStoryCount: 0,
      positiveStoryCount: 0,
      lastUpdated: DateTime.now(),
    ),
    CountryNewsStatus(
      code: 'JP',
      name: 'Japan',
      region: 'Asia',
      latitude: 35,
      longitude: 139,
      currentSeverity: Severity.critical,
      activeStoryCount: 5,
      positiveStoryCount: 0,
      lastUpdated: DateTime.now(),
    ),
  ];

  Future<void> pumpMap(WidgetTester tester) async {
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
  }

  testWidgets('world map exposes list alternative and severity legend text', (
    tester,
  ) async {
    await pumpMap(tester);

    expect(find.text('Critical'), findsWidgets);
    expect(find.text('Country list'), findsOneWidget);
    await tester.tap(find.text('Country list'));
    await tester.pumpAndSettle();
    expect(find.text('Nigeria'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('Accessible country list')),
      findsWidgets,
    );
  });

  testWidgets('country list search and active-only filter work', (
    tester,
  ) async {
    await pumpMap(tester);
    await tester.tap(find.text('Country list'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Showing 3 of 3 countries'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(SearchBar, 'Search countries or regions'),
      'japan',
    );
    await tester.pumpAndSettle();
    expect(find.text('Japan'), findsOneWidget);
    expect(find.text('Nigeria'), findsNothing);
    expect(find.textContaining('Showing 1 of 3 countries'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear country search'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Active stories only'));
    await tester.pumpAndSettle();
    expect(find.text('Barbados'), findsNothing);
    expect(find.text('Nigeria'), findsOneWidget);
    expect(find.text('Japan'), findsOneWidget);
  });

  testWidgets('country list empty state offers reset', (tester) async {
    await pumpMap(tester);
    await tester.tap(find.text('Country list'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(SearchBar, 'Search countries or regions'),
      'zzzz-no-match',
    );
    await tester.pumpAndSettle();

    expect(find.text('No countries match these list filters.'), findsOneWidget);
    expect(find.text('Reset list filters'), findsOneWidget);
    await tester.tap(find.text('Reset list filters'));
    await tester.pumpAndSettle();
    expect(find.text('Nigeria'), findsOneWidget);
    expect(find.textContaining('Showing 3 of 3 countries'), findsOneWidget);
  });

  testWidgets('severity chip narrows country list without colour alone', (
    tester,
  ) async {
    await pumpMap(tester);
    await tester.tap(find.text('Country list'));
    await tester.pumpAndSettle();

    // Severity chip labelled "Critical" (also appears in legend); tap the chip.
    final criticalChips = find.widgetWithText(FilterChip, 'Critical');
    expect(criticalChips, findsWidgets);
    await tester.tap(criticalChips.last);
    await tester.pumpAndSettle();

    expect(find.text('Japan'), findsOneWidget);
    expect(find.text('Nigeria'), findsNothing);
    expect(find.textContaining('Critical severity'), findsWidgets);
  });
}
