import 'dart:convert';

/// Defensive readers for JSON-ish maps.
///
/// Every model in the offline layer goes through these instead of raw casts for
/// three reasons:
///  * Hive hands nested maps back as `Map<dynamic, dynamic>`, not
///    `Map<String, dynamic>` - a direct cast would throw at runtime.
///  * The backend may send `12` where we expect `"12"`, or omit the key
///    entirely while the record is still queued locally.
///  * A single bad field should never blow up a whole list of records.
class JsonUtils {
  const JsonUtils._();

  /// Always returns a `Map<String, dynamic>`; empty when [value] cannot be
  /// interpreted as one.
  static Map<String, dynamic> asMap(dynamic value) {
    if (value == null) return <String, dynamic>{};
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map<String, dynamic>(
        (dynamic key, dynamic item) => MapEntry<String, dynamic>(
          key.toString(),
          item,
        ),
      );
    }
    if (value is String && value.trim().isNotEmpty) {
      try {
        final dynamic decoded = jsonDecode(value);
        if (decoded is Map) return asMap(decoded);
      } catch (_) {
        return <String, dynamic>{};
      }
    }
    return <String, dynamic>{};
  }

  static Map<String, dynamic>? asMapOrNull(dynamic value) {
    if (value == null) return null;
    final Map<String, dynamic> map = asMap(value);
    return map.isEmpty ? null : map;
  }

  /// Accepts a list, a single map, a JSON string or a wrapper map such as
  /// `{"results": [...]}` and returns a normalised list of maps.
  static List<Map<String, dynamic>> asMapList(dynamic value) {
    dynamic source = value;

    if (source is String) {
      if (source.trim().isEmpty) return <Map<String, dynamic>>[];
      try {
        source = jsonDecode(source);
      } catch (_) {
        return <Map<String, dynamic>>[];
      }
    }

    if (source is Map) {
      final Map<String, dynamic> map = asMap(source);
      for (final String key in <String>[
        'results',
        'records',
        'data',
        'items',
        'changes',
      ]) {
        final dynamic nested = map[key];
        if (nested is List) {
          source = nested;
          break;
        }
        if (nested is Map) {
          return asMapList(nested);
        }
      }
    }

    if (source is! List) return <Map<String, dynamic>>[];
    return source
        .where((dynamic item) => item != null)
        .map<Map<String, dynamic>>((dynamic item) => asMap(item))
        .where((Map<String, dynamic> item) => item.isNotEmpty)
        .toList();
  }

  /// Unwraps `{"data": {...}}` / `{"result": {...}}` style envelopes.
  static Map<String, dynamic> unwrap(dynamic value) {
    final Map<String, dynamic> map = asMap(value);
    for (final String key in <String>['data', 'result', 'record']) {
      final dynamic nested = map[key];
      if (nested is Map && nested.isNotEmpty) {
        return asMap(nested);
      }
    }
    return map;
  }

  static String asString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    if (value is String) return value.isEmpty ? fallback : value;
    if (value is num || value is bool) return value.toString();
    final String text = value.toString();
    return text.isEmpty ? fallback : text;
  }

  static String? asStringOrNull(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    final String text = value.toString();
    return text.isEmpty ? null : text;
  }

  static int asInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is bool) return value ? 1 : 0;
    if (value is String) {
      return int.tryParse(value.trim()) ??
          double.tryParse(value.trim())?.toInt() ??
          fallback;
    }
    return fallback;
  }

  static int? asIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value.trim()) ??
          double.tryParse(value.trim())?.toInt();
    }
    return null;
  }

  static double asDouble(dynamic value, {double fallback = 0}) {
    if (value == null) return fallback;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is bool) return value ? 1 : 0;
    if (value is String) {
      return double.tryParse(value.trim()) ?? fallback;
    }
    return fallback;
  }

  static double? asDoubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  static bool asBool(dynamic value, {bool fallback = false}) {
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final String needle = value.trim().toLowerCase();
      if (needle == 'true' || needle == '1' || needle == 'yes') return true;
      if (needle == 'false' || needle == '0' || needle == 'no') return false;
    }
    return fallback;
  }

  static DateTime? asDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) {
      // Tolerate seconds *and* milliseconds since epoch.
      final int millis = value < 100000000000 ? value * 1000 : value;
      return DateTime.fromMillisecondsSinceEpoch(millis);
    }
    if (value is String) {
      final String raw = value.trim();
      if (raw.isEmpty) return null;
      return DateTime.tryParse(raw) ?? DateTime.tryParse(raw.replaceAll(' ', 'T'));
    }
    return null;
  }

  static Duration? asDuration(dynamic value) {
    if (value == null) return null;
    if (value is Duration) return value;
    if (value is num) return Duration(seconds: value.toInt());
    if (value is String) {
      final int? seconds = int.tryParse(value.trim());
      if (seconds != null) return Duration(seconds: seconds);
      final double? asDouble = double.tryParse(value.trim());
      if (asDouble != null) return Duration(seconds: asDouble.toInt());
    }
    return null;
  }

  static List<String> asStringList(dynamic value) {
    if (value == null) return <String>[];
    if (value is List) {
      return value
          .where((dynamic item) => item != null)
          .map<String>((dynamic item) => item.toString())
          .toList();
    }
    if (value is String) {
      if (value.trim().isEmpty) return <String>[];
      return value
          .split(',')
          .map<String>((String item) => item.trim())
          .where((String item) => item.isNotEmpty)
          .toList();
    }
    return <String>[];
  }

  /// `jsonEncode` that can never throw on an unserialisable value.
  static String encodeSafe(Map<String, dynamic> value) {
    try {
      return jsonEncode(value);
    } catch (_) {
      return jsonEncode(
        value.map<String, dynamic>(
          (String key, dynamic item) =>
              MapEntry<String, dynamic>(key, item?.toString()),
        ),
      );
    }
  }

  static Map<String, dynamic> decodeMap(String? value) {
    if (value == null || value.trim().isEmpty) return <String, dynamic>{};
    try {
      final dynamic decoded = jsonDecode(value);
      return asMap(decoded);
    } catch (_) {
      return <String, dynamic>{};
    }
  }
}
