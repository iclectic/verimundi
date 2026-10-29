import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Typed remote-API failures for honest UI copy (British English).
enum RemoteApiErrorKind {
  maintenance,
  rateLimited,
  timeout,
  offline,
  badRequest,
  notFound,
  server,
  cancelled,
  unknown,
}

class RemoteApiException implements Exception {
  const RemoteApiException({
    required this.kind,
    required this.message,
    this.code,
    this.statusCode,
    this.retryAfter,
  });

  final RemoteApiErrorKind kind;
  final String message;
  final String? code;
  final int? statusCode;
  final Duration? retryAfter;

  /// Short headline shown above [message] in feed/error widgets.
  String get title => switch (kind) {
    RemoteApiErrorKind.maintenance => 'Temporarily unavailable',
    RemoteApiErrorKind.rateLimited => 'Too many requests',
    RemoteApiErrorKind.timeout => 'Connection timed out',
    RemoteApiErrorKind.offline => 'Unable to reach VeriMundi',
    RemoteApiErrorKind.badRequest => 'Request could not be completed',
    RemoteApiErrorKind.notFound => 'Not found',
    RemoteApiErrorKind.server => 'Server error',
    RemoteApiErrorKind.cancelled => 'Request cancelled',
    RemoteApiErrorKind.unknown => 'Something went wrong',
  };

  IconData get icon => switch (kind) {
    RemoteApiErrorKind.maintenance => Icons.construction_outlined,
    RemoteApiErrorKind.rateLimited => Icons.hourglass_top,
    RemoteApiErrorKind.timeout => Icons.timer_off_outlined,
    RemoteApiErrorKind.offline => Icons.wifi_off_outlined,
    RemoteApiErrorKind.badRequest => Icons.report_gmailerrorred_outlined,
    RemoteApiErrorKind.notFound => Icons.search_off,
    RemoteApiErrorKind.server => Icons.cloud_off_outlined,
    RemoteApiErrorKind.cancelled => Icons.cancel_outlined,
    RemoteApiErrorKind.unknown => Icons.error_outline,
  };

  /// Hint shown under the detail (pull-to-refresh / wait / update).
  String get recoveryHint => switch (kind) {
    RemoteApiErrorKind.maintenance =>
      'Please try again shortly. Pull to refresh when ready.',
    RemoteApiErrorKind.rateLimited =>
      retryAfter != null
          ? 'Please wait about ${retryAfter!.inSeconds} seconds, then try again.'
          : 'Please wait a moment, then try again.',
    RemoteApiErrorKind.timeout || RemoteApiErrorKind.offline =>
      'Check your connection, then pull to refresh.',
    RemoteApiErrorKind.server => 'Pull to refresh or try again later.',
    _ => 'Pull to refresh or try again.',
  };

  @override
  String toString() => 'RemoteApiException($kind, $statusCode, $message)';

  /// Maps Dio failures (and optional JSON `{code,message}`) to a typed error.
  static RemoteApiException fromDio(DioException error, {String? baseUrlHint}) {
    final status = error.response?.statusCode;
    final data = error.response?.data;
    String? code;
    String? message;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      code = map['code'] as String?;
      message = map['message'] as String? ?? map['detail'] as String?;
    }

    final retryAfter = _parseRetryAfter(
      error.response?.headers.value('retry-after'),
    );

    if (error.type == DioExceptionType.cancel) {
      return const RemoteApiException(
        kind: RemoteApiErrorKind.cancelled,
        message: 'The request was cancelled.',
        code: 'cancelled',
      );
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const RemoteApiException(
        kind: RemoteApiErrorKind.timeout,
        message: 'Timed out contacting the VeriMundi API.',
        code: 'timeout',
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      final hint = baseUrlHint == null || baseUrlHint.isEmpty
          ? 'the VeriMundi API'
          : baseUrlHint;
      return RemoteApiException(
        kind: RemoteApiErrorKind.offline,
        message: 'Unable to reach $hint.',
        code: 'offline',
      );
    }

    if (status == 429 ||
        code == 'rate_limited' ||
        code == 'ask_rate_limited' ||
        code == 'report_rate_limited') {
      return RemoteApiException(
        kind: RemoteApiErrorKind.rateLimited,
        message: message ?? 'Rate limit exceeded. Please try again later.',
        code: code ?? 'rate_limited',
        statusCode: status,
        retryAfter: retryAfter ?? const Duration(seconds: 60),
      );
    }

    if (status == 503 || code == 'maintenance') {
      return RemoteApiException(
        kind: RemoteApiErrorKind.maintenance,
        message:
            message ?? 'VeriMundi is temporarily unavailable for maintenance.',
        code: code ?? 'maintenance',
        statusCode: status,
        retryAfter: retryAfter,
      );
    }

    if (status == 404 ||
        code == 'story_not_found' ||
        code == 'country_not_found') {
      return RemoteApiException(
        kind: RemoteApiErrorKind.notFound,
        message: message ?? 'The requested resource was not found.',
        code: code ?? 'not_found',
        statusCode: status,
      );
    }

    if (status != null && status >= 400 && status < 500) {
      return RemoteApiException(
        kind: RemoteApiErrorKind.badRequest,
        message: message ?? 'The request was rejected by the server.',
        code: code ?? 'bad_request',
        statusCode: status,
      );
    }

    if (status != null && status >= 500) {
      return RemoteApiException(
        kind: RemoteApiErrorKind.server,
        message: message ?? 'The VeriMundi API returned an unexpected error.',
        code: code ?? 'server_error',
        statusCode: status,
      );
    }

    return RemoteApiException(
      kind: RemoteApiErrorKind.unknown,
      message:
          message ??
          'VeriMundi API request failed${status != null ? ' (HTTP $status)' : ''}.',
      code: code,
      statusCode: status,
    );
  }

  static Duration? _parseRetryAfter(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final seconds = int.tryParse(raw.trim());
    if (seconds == null || seconds < 0) return null;
    return Duration(seconds: seconds);
  }
}
