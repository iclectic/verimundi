import 'package:dio/dio.dart';

import '../constants/app_constants.dart';

enum AppDataMode { mock, remoteUnavailable }

class ApiClient {
  ApiClient()
    : dio = Dio(
        BaseOptions(
          baseUrl: AppConstants.apiBaseUrl == 'mock'
              ? ''
              : AppConstants.apiBaseUrl,
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 12),
        ),
      );

  final Dio dio;

  bool get isMockMode => AppConstants.apiBaseUrl == 'mock';

  AppDataMode get dataMode =>
      isMockMode ? AppDataMode.mock : AppDataMode.remoteUnavailable;

  String get modeDescription => switch (dataMode) {
    AppDataMode.mock => 'Mock data mode',
    AppDataMode.remoteUnavailable => 'Remote backend unavailable',
  };
}
