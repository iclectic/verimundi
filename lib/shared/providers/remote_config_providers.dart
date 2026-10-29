import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/app_remote_config.dart';
import 'core_providers.dart';

/// Soft-fails on transport/parse issues so banners stay optional.
/// Programming errors (e.g. [StateError]) are not swallowed.
final remoteAppConfigProvider = FutureProvider<AppRemoteConfig?>((ref) async {
  final client = ref.watch(apiClientProvider);
  if (client.isMockMode) {
    return null;
  }
  try {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/v1/app/config',
    );
    final data = response.data;
    if (data == null) return null;
    return AppRemoteConfig.fromJson(data);
  } on DioException {
    return null;
  } on FormatException {
    return null;
  }
});
