import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verimundi/core/network/remote_api_exception.dart';

void main() {
  group('RemoteApiException.fromDio', () {
    test('maps maintenance 503 with API code', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/v1/stories'),
        response: Response(
          requestOptions: RequestOptions(path: '/v1/stories'),
          statusCode: 503,
          data: {
            'code': 'maintenance',
            'message': 'Back soon for maintenance.',
          },
          headers: Headers.fromMap({
            'retry-after': ['120'],
          }),
        ),
        type: DioExceptionType.badResponse,
      );

      final mapped = RemoteApiException.fromDio(error);
      expect(mapped.kind, RemoteApiErrorKind.maintenance);
      expect(mapped.message, 'Back soon for maintenance.');
      expect(mapped.retryAfter, const Duration(seconds: 120));
      expect(mapped.title, 'Temporarily unavailable');
    });

    test('maps rate limit 429', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/v1/stories/x/questions'),
        response: Response(
          requestOptions: RequestOptions(path: '/v1/stories/x/questions'),
          statusCode: 429,
          data: {
            'code': 'rate_limited',
            'message': 'Too many requests. Please wait a minute and try again.',
          },
          headers: Headers.fromMap({
            'retry-after': ['60'],
          }),
        ),
        type: DioExceptionType.badResponse,
      );

      final mapped = RemoteApiException.fromDio(error);
      expect(mapped.kind, RemoteApiErrorKind.rateLimited);
      expect(mapped.retryAfter, const Duration(seconds: 60));
      expect(mapped.recoveryHint, contains('60'));
    });

    test('maps connection timeout', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/v1/stories'),
        type: DioExceptionType.connectionTimeout,
      );

      final mapped = RemoteApiException.fromDio(error);
      expect(mapped.kind, RemoteApiErrorKind.timeout);
      expect(mapped.icon, isNotNull);
    });

    test('maps connection error with base URL hint', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/v1/stories'),
        type: DioExceptionType.connectionError,
      );

      final mapped = RemoteApiException.fromDio(
        error,
        baseUrlHint: 'http://localhost:5080',
      );
      expect(mapped.kind, RemoteApiErrorKind.offline);
      expect(mapped.message, contains('http://localhost:5080'));
    });

    test('maps server 500', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/v1/stories'),
        response: Response(
          requestOptions: RequestOptions(path: '/v1/stories'),
          statusCode: 500,
          data: 'boom',
        ),
        type: DioExceptionType.badResponse,
      );

      final mapped = RemoteApiException.fromDio(error);
      expect(mapped.kind, RemoteApiErrorKind.server);
      expect(mapped.statusCode, 500);
    });
  });
}
