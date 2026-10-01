import 'package:lekhan_ai/core/utils/json_utils.dart';

/// Normalises the envelope variations used by REST backends without allowing
/// malformed response data to crash a list screen or background sync pass.
class RemoteJsonUtils {
  const RemoteJsonUtils._();

  static const List<String> _collectionKeys = <String>[
    'results',
    'records',
    'items',
    'projects',
    'books',
    'chapters',
    'sources',
    'changes',
    'deleted',
    'data',
    'result',
  ];

  /// Finds a list inside common API envelopes such as
  /// `{ "data": { "results": [...] } }` or `{ "items": [...] }`.
  static List<Map<String, dynamic>> records(dynamic value) {
    dynamic current = value;

    for (int depth = 0; depth < 5; depth++) {
      if (current is List) {
        return current
            .where((dynamic item) => item != null)
            .map<Map<String, dynamic>>(JsonUtils.asMap)
            .where((Map<String, dynamic> item) => item.isNotEmpty)
            .toList(growable: false);
      }

      final Map<String, dynamic> map = JsonUtils.asMap(current);
      if (map.isEmpty) return const <Map<String, dynamic>>[];

      dynamic nested;
      for (final String key in _collectionKeys) {
        if (map.containsKey(key) && map[key] != null) {
          nested = map[key];
          break;
        }
      }

      if (nested == null) {
        if (remoteId(map).isNotEmpty) {
          return <Map<String, dynamic>>[map];
        }
        return const <Map<String, dynamic>>[];
      }
      current = nested;
    }

    return const <Map<String, dynamic>>[];
  }

  /// Unwraps a detail envelope (`data`, `result`, `record`, or `item`).
  static Map<String, dynamic> record(dynamic value) {
    Map<String, dynamic> map = JsonUtils.asMap(value);
    for (int depth = 0; depth < 5; depth++) {
      dynamic nested;
      for (final String key in <String>[
        'data',
        'result',
        'record',
        'item',
      ]) {
        final Map<String, dynamic> candidate = JsonUtils.asMap(map[key]);
        if (candidate.isNotEmpty) {
          nested = candidate;
          break;
        }
      }
      if (nested == null) return map;
      map = JsonUtils.asMap(nested);
    }
    return map;
  }

  /// Unwraps a resource-specific detail envelope without mistaking a nested
  /// parent relation on a normal record for the record itself.
  static Map<String, dynamic> detailRecord(
    dynamic value, {
    required String entityKey,
  }) {
    final Map<String, dynamic> map = record(value);
    final Map<String, dynamic> nested = JsonUtils.asMap(map[entityKey]);
    return nested.isEmpty ? map : record(nested);
  }

  /// Remote identifiers are exposed as `id` by most REST APIs and as
  /// `remote_id` by the sync API. `pk` is tolerated for Django-style models.
  static String remoteId(Map<String, dynamic> json) {
    return JsonUtils.asString(
      json['remote_id'] ??
          json['record_id'] ??
          json['object_id'] ??
          json['id'] ??
          json['pk'] ??
          json['uuid'],
    );
  }

  /// Adapts a server record to the local model convention: server identity is
  /// available in both `id` and `remote_id`. Repositories may replace `id`
  /// with an existing device id when merging into the cache.
  static Map<String, dynamic> withRemoteIdentity(
    Map<String, dynamic> json, {
    String? id,
  }) {
    final Map<String, dynamic> result = Map<String, dynamic>.of(json);
    final String remote = remoteId(json);
    final String local = id ?? remote;
    if (local.isNotEmpty) result['id'] = local;
    if (remote.isNotEmpty) result['remote_id'] = remote;

    result.putIfAbsent('created_at', () => json['createdAt']);
    result.putIfAbsent('updated_at', () => json['updatedAt']);
    return result;
  }
}
