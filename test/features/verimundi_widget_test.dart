import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verimundi/app/app.dart';
import 'package:verimundi/core/constants/app_constants.dart';
import 'package:verimundi/core/database/app_database.dart';
import 'package:verimundi/features/world/presentation/world_map_view.dart';
import 'package:verimundi/shared/models/news_models.dart';
import 'package:verimundi/shared/providers/app_providers.dart';

import '../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpFrames(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
  }

  testWidgets('VeriMundi app renders, switches mode, and opens details', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const VeriMundiApp(),
      ),
    );
    await pumpFrames(tester);

    expect(find.text('VeriMundi'), findsOneWidget);
    expect(find.text(AppConstants.demoBanner), findsWidgets);
    expect(
      find.text('River districts test new flood warning sirens'),
      findsWidgets,
    );

    await tester.tap(find.text('Positive World'));
    await pumpFrames(tester);
    expect(find.textContaining('Wetland restoration'), findsWidgets);

    await tester.tap(find.text('World Pulse'));
    await pumpFrames(tester);
    await tester.ensureVisible(
      find.text('River districts test new flood warning sirens').first,
    );
    await pumpFrames(tester);
    await tester.tap(
      find.text('River districts test new flood warning sirens').first,
    );
    await pumpFrames(tester);
    expect(find.text('AI-generated summary'), findsOneWidget);
    expect(find.text('What remains uncertain'), findsOneWidget);
    expect(find.text('Sources'), findsOneWidget);
  });

  testWidgets('WorldMapView opens a country bottom sheet from a marker', (
    tester,
  ) async {
    final country = CountryNewsStatus(
      code: 'GH',
      name: 'Ghana',
      region: 'Africa',
      latitude: 7.95,
      longitude: -1.02,
      currentSeverity: Severity.developing,
      activeStoryCount: 2,
      positiveStoryCount: 1,
      lastUpdated: DateTime.utc(2026, 7, 12),
    );
    final story = storyFixture(
      id: 'map-story',
      headline: 'Schools pilot solar study halls',
      country: 'GH',
      tone: Tone.positive,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorldMapView(countries: [country], stories: [story]),
        ),
      ),
    );
    await pumpFrames(tester);
    await tester.tap(find.byType(IconButton));
    await pumpFrames(tester);

    expect(find.text('Ghana'), findsWidgets);
    expect(find.textContaining('developing severity'), findsOneWidget);
    expect(find.text('Schools pilot solar study halls'), findsOneWidget);
  });
}
