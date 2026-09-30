import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:lekhan_ai/core/database/app_database.dart';
import 'package:lekhan_ai/core/utils/json_utils.dart';

/// Generic document collection on top of a Hive box.
///
/// Every local datasource in the app is a thin wrapper around this: one model,
/// one box, one id field. Keeping the Hive specifics here means:
///  * the datasources stay readable and free of `Map<dynamic, dynamic>` casts,
///  * a future move to SQLite/Drift touches exactly this file,
///  * feature code never opens a box directly.
class DocumentStore<T> {
  DocumentStore({
    required this.database,
    required this.boxName,
    required T Function(Map<String, dynamic> json) fromJson,
    required Map<String, dynamic> Function(T item) toJson,
    required String Function(T item) idOf,
  })  : _fromJson = fromJson,
        _toJson = toJson,
        _idOf = idOf;

  final AppDatabase database;
  final String boxName;
  final T Function(Map<String, dynamic> json) _fromJson;
  final Map<String, dynamic> Function(T item) _toJson;
  final String Function(T item) _idOf;

  bool get isReady => database.isBoxOpen(boxName);

  Box<dynamic> get _box => database.box(boxName);

  List<T> get _decoded {
    return _box.values
        .map<Map<String, dynamic>>((dynamic value) => JsonUtils.asMap(value))
        .where((Map<String, dynamic> value) => value.isNotEmpty)
        .map<T>(_fromJson)
        .toList();
  }

  Future<List<T>> readAll() async => _decoded;

  Future<T?> readById(String id) async {
    final dynamic value = _box.get(id);
    if (value == null) return null;
    final Map<String, dynamic> map = JsonUtils.asMap(value);
    if (map.isEmpty) return null;
    return _fromJson(map);
  }

  /// Default lookup used by the pull pipeline: remote id first, local id as
  /// fallback, so a record that just came back from the server still finds its
  /// local twin.
  Future<T?> readByAnyId(String id, {String? remoteId}) async {
    final T? byLocal = await readById(id);
    if (byLocal != null) return byLocal;

    final String? remote = remoteId;
    if (remote == null || remote.isEmpty) return null;

    for (final T item in _decoded) {
      final Map<String, dynamic> json = _toJson(item);
      if (json['remote_id'] == remote) return item;
    }
    return null;
  }

  Future<List<T>> where(bool Function(T item) test) async {
    return _decoded.where(test).toList();
  }

  Future<void> write(T item) async {
    await _box.put(_idOf(item), _toJson(item));
  }

  Future<void> writeAll(List<T> items) async {
    if (items.isEmpty) return;
    final Map<String, dynamic> entries = <String, dynamic>{
      for (final T item in items) _idOf(item): _toJson(item),
    };
    await _box.putAll(entries);
  }

  Future<void> delete(String id) => _box.delete(id);

  Future<void> clear() => _box.clear();

  Future<int> count() async => _box.length;

  /// Emits the collection on subscribe and after every change to the box.
  Stream<List<T>> watch() async* {
    yield _decoded;
    await for (final _ in _box.watch()) {
      yield _decoded;
    }
  }
}
