import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verimundi/app/app.dart';
import 'package:verimundi/core/database/app_database.dart';
import 'package:verimundi/shared/providers/app_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpFrames(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
  }

  testWidgets('core shell exposes semantic labels and tolerates large text', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final semanticsHandle = tester.ensureSemantics();

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(390, 844),
          textScaler: TextScaler.linear(1.4),
        ),
        child: ProviderScope(
          overrides: [databaseProvider.overrideWithValue(database)],
          child: const VeriMundiApp(),
        ),
      ),
    );
    await pumpFrames(tester);

    expect(find.text('VeriMundi'), findsOneWidget);
    expect(find.text('World Pulse'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('fictional demo content')),
      findsWidgets,
    );
    expect(find.bySemanticsLabel(RegExp('World map')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Save')), findsWidgets);

    semanticsHandle.dispose();
  });
}
