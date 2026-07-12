import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verimundi/app/app.dart';
import 'package:verimundi/core/constants/app_constants.dart';
import 'package:verimundi/core/database/app_database.dart';
import 'package:verimundi/shared/providers/app_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<AppDatabase> pumpApp(WidgetTester tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const VeriMundiApp(),
      ),
    );
    await tester.pumpAndSettle();
    return database;
  }

  testWidgets('World screen renders dashboard and demo banner', (tester) async {
    final database = await pumpApp(tester);
    addTearDown(database.close);

    expect(find.text('VeriMundi'), findsOneWidget);
    expect(find.text(AppConstants.demoBanner), findsWidgets);
    expect(find.text('World Pulse'), findsOneWidget);
    expect(find.text('Regional sections'), findsOneWidget);
  });

  testWidgets('switching feed modes updates the dashboard perspective', (tester) async {
    final database = await pumpApp(tester);
    addTearDown(database.close);

    await tester.tap(find.text('Positive World'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Positive impact score'), findsWidgets);
  });

  testWidgets('country marker opens a bottom sheet', (tester) async {
    final database = await pumpApp(tester);
    addTearDown(database.close);

    await tester.tap(find.byTooltip('Nepal: critical'));
    await tester.pumpAndSettle();

    expect(find.text('Nepal'), findsWidgets);
    expect(find.textContaining('critical severity'), findsOneWidget);
  });

  testWidgets('opening a story shows uncertainty and sources sections', (tester) async {
    final database = await pumpApp(tester);
    addTearDown(database.close);

    await tester.tap(find.text('River districts test new flood warning sirens').first);
    await tester.pumpAndSettle();

    expect(find.text('AI-generated summary'), findsOneWidget);
    expect(find.text('What remains uncertain'), findsOneWidget);
    expect(find.text('Sources'), findsOneWidget);
  });

  testWidgets('saving and unsaving a story changes saved state', (tester) async {
    final database = await pumpApp(tester);
    addTearDown(database.close);

    await tester.tap(find.byTooltip('Save story').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();

    expect(find.textContaining('River districts test'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove saved story').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('River districts test'), findsNothing);
  });
}
