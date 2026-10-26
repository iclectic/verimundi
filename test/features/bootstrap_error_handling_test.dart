import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verimundi/core/network/remote_api_exception.dart';
import 'package:verimundi/shared/widgets/async_value_view.dart';

void main() {
  testWidgets('AsyncValueView shows safe StateError details', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AsyncValueView<List<String>>(
            value: AsyncError(
              StateError('Remote backend unavailable for this release.'),
              StackTrace.empty,
            ),
            builder: _NeverBuild.new,
          ),
        ),
      ),
    );

    expect(
      find.text('Something went wrong. Pull to refresh or try again.'),
      findsOneWidget,
    );
    expect(
      find.text('Remote backend unavailable for this release.'),
      findsOneWidget,
    );
  });

  testWidgets('AsyncValueView shows typed RemoteApiException copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AsyncValueView<List<String>>(
            value: AsyncError(
              const RemoteApiException(
                kind: RemoteApiErrorKind.offline,
                message: 'Unable to reach http://localhost:5080.',
                code: 'offline',
              ),
              StackTrace.empty,
            ),
            builder: _NeverBuild.new,
          ),
        ),
      ),
    );

    expect(find.text('Unable to reach VeriMundi'), findsOneWidget);
    expect(
      find.textContaining('Unable to reach http://localhost:5080.'),
      findsOneWidget,
    );
    expect(find.textContaining('Check your connection'), findsOneWidget);
  });
}

class _NeverBuild extends StatelessWidget {
  const _NeverBuild(this.values);

  final List<String> values;

  @override
  Widget build(BuildContext context) {
    throw StateError('Unexpected build for $values');
  }
}
