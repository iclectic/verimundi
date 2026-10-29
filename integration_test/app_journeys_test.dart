import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:verimundi/app/app.dart';
import 'package:verimundi/core/database/app_database.dart';
import 'package:verimundi/shared/providers/app_providers.dart';

/// Mock integration journeys (Phase 7: feed → detail → Ask/report).
/// Prefer `flutter test integration_test -d flutter-tester` locally.
/// CI also covers the Ask/report path via `test/features/ask_report_journey_test.dart`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpFrames(WidgetTester tester, {int count = 12}) async {
    for (var i = 0; i < count; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
  }

  Future<void> pumpApp(WidgetTester tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const VeriMundiApp(),
      ),
    );
    await pumpFrames(tester);
  }

  testWidgets('main demo journeys load and navigate', (tester) async {
    await pumpApp(tester);

    expect(find.text('VeriMundi'), findsOneWidget);
    expect(find.textContaining('fictional demo content'), findsWidgets);

    await tester.tap(find.text('Positive World'));
    await pumpFrames(tester);
    expect(find.textContaining('Wetland restoration'), findsWidgets);

    await tester.tap(find.text('Saved'));
    await pumpFrames(tester);
    expect(find.text('No saved stories yet.'), findsOneWidget);
  });

  testWidgets('feed detail Ask mock AI and report happy path', (tester) async {
    await pumpApp(tester);

    expect(find.text('VeriMundi'), findsOneWidget);

    final headline = find.text('River districts test new flood warning sirens');
    expect(headline, findsWidgets);
    await tester.ensureVisible(headline.first);
    await pumpFrames(tester, count: 4);
    await tester.tap(headline.first);
    await pumpFrames(tester);

    expect(find.text('Ask about this story'), findsOneWidget);
    expect(find.text('Ask mock AI'), findsOneWidget);

    await tester.ensureVisible(find.text('Ask mock AI'));
    await pumpFrames(tester, count: 4);
    final questionField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'Question',
    );
    expect(questionField, findsOneWidget);
    await tester.enterText(questionField, 'What is the key point?');
    await tester.tap(find.text('Ask mock AI'));
    await pumpFrames(tester, count: 20);

    expect(find.text('AI-generated response'), findsOneWidget);
    expect(
      find.textContaining('Based only on the listed demo sources'),
      findsOneWidget,
    );
    expect(find.text('Insufficient evidence'), findsNothing);

    await tester.tap(find.byTooltip('Report a problem'));
    await pumpFrames(tester, count: 8);
    expect(find.text('Report a problem'), findsWidgets);
    expect(find.text('Submit report'), findsOneWidget);
    await tester.tap(find.text('Submit report'));
    await pumpFrames(tester, count: 12);

    expect(
      find.textContaining('Demo mode: report noted locally only'),
      findsOneWidget,
    );
  });
}
