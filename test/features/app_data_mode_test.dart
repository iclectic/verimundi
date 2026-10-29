import 'package:flutter_test/flutter_test.dart';
import 'package:verimundi/core/network/api_client.dart';

void main() {
  test('production plus mock is misconfigured and never silent', () {
    expect(
      resolveAppDataMode(appEnv: 'production', apiBaseUrl: 'mock'),
      AppDataMode.misconfigured,
    );
  });

  test('prod alias plus blank base is misconfigured', () {
    expect(
      resolveAppDataMode(appEnv: 'prod', apiBaseUrl: '  '),
      AppDataMode.misconfigured,
    );
  });

  test('production rejects non-http remote URLs', () {
    expect(
      resolveAppDataMode(appEnv: 'production', apiBaseUrl: 'not-a-url'),
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

  test('production with https remote is allowed', () {
    expect(
      resolveAppDataMode(
        appEnv: 'production',
        apiBaseUrl: 'https://api.verimundi.example',
      ),
      AppDataMode.remote,
    );
  });
}
