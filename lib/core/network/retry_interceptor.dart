import 'dart:async';

import 'package:dio/dio.dart';

/// Retries idempotent GET requests on transient network/5xx failures.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    this.maxRetries = 2,
    this.retryDelay = const Duration(milliseconds: 400),
  });

  final int maxRetries;
  final Duration retryDelay;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final attempt = (request.extra['retryAttempt'] as int?) ?? 0;
    final method = request.method.toUpperCase();
    final status = err.response?.statusCode;
    // Do not retry 503 — maintenance mode and overload both use it; the UI
    // should surface the server message rather than delaying on retries.
    final transient =
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        status == 502 ||
        status == 504;

    if (method != 'GET' || !transient || attempt >= maxRetries) {
      handler.next(err);
      return;
    }

    request.extra['retryAttempt'] = attempt + 1;
    await Future<void>.delayed(retryDelay * (attempt + 1));
    try {
      final response = await Dio(
        BaseOptions(
          baseUrl: request.baseUrl,
          connectTimeout: request.connectTimeout,
          receiveTimeout: request.receiveTimeout,
          headers: request.headers,
        ),
      ).fetch(request);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
