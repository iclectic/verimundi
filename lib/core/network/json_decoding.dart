/// Lenient JSON helpers for remote API payloads.
///
/// Prefers [FormatException] over raw cast [TypeError]s (e.g. `num`→`int`,
/// non-Map list items) so Dio failures stay distinguishable from contract drift.
class JsonDecoding {
  const JsonDecoding._();

  static Map<String, dynamic> asObject(
    dynamic value, {
    required String context,
  }) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    throw FormatException('$context: expected a JSON object');
  }

  static Map<String, dynamic>? asObjectOrNull(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  static List<dynamic> asList(dynamic value, {List<dynamic>? fallback}) {
    if (value is List<dynamic>) {
      return value;
    }
    if (value is List) {
      return List<dynamic>.from(value);
    }
    return fallback ?? const [];
  }

  static String asString(dynamic value, {String fallback = ''}) {
    if (value == null) {
      return fallback;
    }
    if (value is String) {
      return value;
    }
    return value.toString();
  }

  static String? asStringOrNull(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return value;
    }
    return value.toString();
  }

  static int asInt(dynamic value, {int fallback = 0}) {
    if (value == null) {
      return fallback;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  static double asDouble(dynamic value, {double fallback = 0}) {
    if (value == null) {
      return fallback;
    }
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  static bool asBool(dynamic value, {bool fallback = false}) {
    if (value == null) {
      return fallback;
    }
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') {
        return true;
      }
      if (normalized == 'false' || normalized == '0') {
        return false;
      }
    }
    return fallback;
  }

  static List<String> asStringList(dynamic value) {
    return asList(value).map(asString).toList();
  }

  static DateTime asDateTime(dynamic value, {DateTime? fallback}) {
    final resolvedFallback = fallback ?? DateTime.now().toUtc();
    if (value is String) {
      return DateTime.tryParse(value)?.toUtc() ?? resolvedFallback;
    }
    return resolvedFallback;
  }

  static DateTime? asDateTimeOrNull(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return DateTime.tryParse(value)?.toUtc();
    }
    return null;
  }
}
