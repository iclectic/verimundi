import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verimundi/features/stories/presentation/story_detail_screen.dart';
import 'package:verimundi/shared/models/news_models.dart';
import 'package:verimundi/shared/providers/app_providers.dart';

import '../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('story detail exposes timeline, ranking, disputes, and labels', (
    tester,
  ) async {
    final semanticsHandle = tester.ensureSemantics();
    final story =
        storyFixture(
          id: 'detail-1',
          headline: 'Accessible story headline',
        ).copyWith(
          fullSummary: 'A longer full summary that differs from the short one.',
          rankingReason: 'Ranked for regional balance and severity.',
          underreportedReason: 'Local outlets outweigh international coverage.',
          disputedClaims: const [
            DisputedClaim(
              text: 'Casualty figures remain contested.',
              supportingSourceIds: ['a'],
              disputingSourceIds: ['b'],
            ),
          ],
          correctionNotice: 'Updated after a source correction.',
          correctedAt: DateTime.utc(2026, 10, 20, 9),
          verificationStatus: VerificationStatus.corrected,
          category: StoryCategory.humanRights,
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storyByIdProvider('detail-1').overrideWith((ref) async => story),
        ],
        child: const MaterialApp(home: StoryDetailScreen(storyId: 'detail-1')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Accessible story headline'), findsOneWidget);
    expect(find.text('Timeline'), findsOneWidget);
    expect(find.text('Full summary'), findsOneWidget);
    expect(find.textContaining('longer full summary'), findsOneWidget);
    expect(find.text('Disputed or conflicting claims'), findsOneWidget);
    expect(find.textContaining('Casualty figures'), findsOneWidget);
    expect(find.text('Why VeriMundi ranked this story'), findsOneWidget);
    expect(find.textContaining('Ranked for regional balance'), findsOneWidget);
    expect(find.textContaining('Correction:'), findsOneWidget);
    expect(find.text('Human rights'), findsOneWidget);
    expect(find.text('Corrected'), findsOneWidget);
    expect(find.text('Ask about this story'), findsOneWidget);
    expect(find.byTooltip('Report a problem'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Correction notice')), findsOneWidget);

    semanticsHandle.dispose();
  });

  testWidgets('story detail tolerates large text scale', (tester) async {
    final story = storyFixture(id: 'detail-2');
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(390, 844),
          textScaler: TextScaler.linear(1.6),
        ),
        child: ProviderScope(
          overrides: [
            storyByIdProvider('detail-2').overrideWith((ref) async => story),
          ],
          child: const MaterialApp(
            home: StoryDetailScreen(storyId: 'detail-2'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Timeline'), findsOneWidget);
    expect(find.text('AI-generated summary'), findsOneWidget);
    expect(find.text('Sources'), findsOneWidget);
  });
}
