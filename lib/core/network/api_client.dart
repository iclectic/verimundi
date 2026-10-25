import 'package:dio/dio.dart';

import '../constants/app_constants.dart';

enum AppDataMode { mock, remote, misconfigured }

AppDataMode resolveAppDataMode({
  required String appEnv,
  required String apiBaseUrl,
}) {
  final isMock = apiBaseUrl == 'mock';
  final isProduction = appEnv.toLowerCase() == 'production';
  if (isProduction && isMock) {
    return AppDataMode.misconfigured;
  }
  if (isMock) {
    return AppDataMode.mock;
  }
  return AppDataMode.remote;
}

class ApiClient {
  ApiClient({Dio? dio})
    : dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AppConstants.isMockApi ? '' : AppConstants.apiBaseUrl,
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 12),
              headers: const {'Accept': 'application/json'},
            ),
          ) {
    validateConfiguration();
  }

  final Dio dio;

  bool get isMockMode => dataMode == AppDataMode.mock;

  AppDataMode get dataMode => resolveAppDataMode(
    appEnv: AppConstants.appEnv,
    apiBaseUrl: AppConstants.apiBaseUrl,
  );

  void validateConfiguration() {
    if (dataMode == AppDataMode.misconfigured) {
      throw StateError(
        'APP_ENV=production cannot use NEWS_API_BASE_URL=mock. '
        'Production builds must never silently fall back to fictional content.',
      );
    }
  }

  String get modeDescription => switch (dataMode) {
    AppDataMode.mock => 'Mock data mode',
    AppDataMode.remote => 'Remote API mode (${AppConstants.appEnv})',
    AppDataMode.misconfigured => 'Misconfigured production mock mode',
  };
}
