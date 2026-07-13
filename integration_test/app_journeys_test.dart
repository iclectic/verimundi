import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:verimundi/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('main demo journeys load and navigate', (tester) async {
    app.main();

    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }

    expect(find.text('VeriMundi'), findsOneWidget);
    expect(find.textContaining('fictional demo content'), findsWidgets);

    await tester.tap(find.text('Positive'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Wetland restoration'), findsWidgets);

    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();
    expect(find.text('No saved stories yet.'), findsOneWidget);
  });
}
