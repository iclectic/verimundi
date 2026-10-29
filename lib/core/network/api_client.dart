import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import 'retry_interceptor.dart';

enum AppDataMode { mock, remote, misconfigured }

AppDataMode resolveAppDataMode({
  required String appEnv,
  required String apiBaseUrl,
}) {
  final env = appEnv.trim().toLowerCase();
  final base = apiBaseUrl.trim();
  // Treat blank / literal "mock" as mock. Production must never land here silently.
  final isMock = base.isEmpty || base.toLowerCase() == 'mock';
  final isProduction = env == 'production' || env == 'prod';
  if (isProduction && isMock) {
    return AppDataMode.misconfigured;
  }
  if (isMock) {
    return AppDataMode.mock;
  }
  // Production remote URLs must be absolute http(s) — refuse relative/opaque values.
  if (isProduction) {
    final uri = Uri.tryParse(base);
    final okScheme =
        uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    if (!okScheme) {
      return AppDataMode.misconfigured;
    }
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
    if (!AppConstants.isMockApi) {
      this.dio.interceptors.add(RetryInterceptor());
    }
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
        'APP_ENV=production requires a live http(s) NEWS_API_BASE_URL. '
        'Production builds must never silently fall back to fictional/mock content.',
      );
    }
  }

  String get modeDescription => switch (dataMode) {
    AppDataMode.mock => 'Mock data mode',
    AppDataMode.remote => 'Remote API mode (${AppConstants.appEnv})',
    AppDataMode.misconfigured => 'Misconfigured production mock mode',
  };
}
