import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verimundi/shared/providers/app_providers.dart';
import 'package:verimundi/shared/widgets/filter_bar.dart';

void main() {
  testWidgets('FilterBar debounces search and shows dismissible chips', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: FilterBar())),
      ),
    );

    await tester.enterText(find.byType(SearchBar), 'clinic hours');
    await tester.pump();
    // Before debounce fires, provider should still be empty.
    final container = ProviderScope.containerOf(
      tester.element(find.byType(FilterBar)),
    );
    expect(container.read(storyFilterProvider).query, isNull);

    await tester.pump(const Duration(milliseconds: 350));
    expect(container.read(storyFilterProvider).query, 'clinic hours');
    expect(container.read(feedPageProvider), 1);
    expect(find.text('Search: clinic hours'), findsOneWidget);

    final deleteChip = find.descendant(
      of: find.widgetWithText(InputChip, 'Search: clinic hours'),
      matching: find.byTooltip('Delete'),
    );
    expect(deleteChip, findsOneWidget);
    await tester.tap(deleteChip);
    await tester.pumpAndSettle();
    expect(container.read(storyFilterProvider).query, isNull);
  });
}
