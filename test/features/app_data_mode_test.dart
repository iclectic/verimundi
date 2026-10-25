import 'package:flutter_test/flutter_test.dart';
import 'package:verimundi/core/network/api_client.dart';

void main() {
  test('production plus mock is misconfigured and never silent', () {
    expect(
      resolveAppDataMode(appEnv: 'production', apiBaseUrl: 'mock'),
      AppDataMode.misconfigured,
    );
  });

  test('development mock remains available', () {
    expect(
      resolveAppDataMode(appEnv: 'development', apiBaseUrl: 'mock'),
      AppDataMode.mock,
    );
  });

  test('staging remote is remote mode', () {
    expect(
      resolveAppDataMode(
        appEnv: 'staging',
        apiBaseUrl: 'https://api.example.com',
      ),
      AppDataMode.remote,
    );
  });
}
