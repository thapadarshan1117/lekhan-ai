import 'dart:developer';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:lekhan_ai/core/database/database_migrations.dart';
import 'package:lekhan_ai/core/database/database_tables.dart';
import 'package:lekhan_ai/core/utils/json_utils.dart';

/// Owns the Hive boxes that make up the offline application state.
///
/// Why Hive (and not SQLite): it is already a dependency of this project and is
/// already used through `HiveService`, it needs no code generation, and every
/// entity here is a small document that is always read whole. All access goes
/// through the datasources, so swapping the engine later means rewriting the
/// datasources only - never the domain layer.
///
/// Documents are stored as `Map<String, dynamic>` (JSON shape) so the very same
/// map can be reused as a sync payload.
class AppDatabase {
  final Map<String, Box<dynamic>> _boxes = <String, Box<dynamic>>{};
  bool _initialized = false;

  bool get isInitialized => _initialized;

  /// Opens every box and runs pending migrations. Safe to call more than once.
  Future<void> init() async {
    if (_initialized) return;

    try {
      await Hive.initFlutter();
    } catch (error) {
      // `main()` and `HiveService` also call this; a second call is harmless
      // but must never stop the app from starting.
      log('AppDatabase: Hive.initFlutter() skipped ($error)');
    }

    for (final String name in DatabaseTables.allBoxes) {
      _boxes[name] = await Hive.openBox<dynamic>(name);
    }

    await DatabaseMigrations(metaBox: box(DatabaseTables.meta)).run();
    _initialized = true;
  }

  /// Throws [StateError] when called before [init] - that is a programming
  /// error, not a runtime condition worth swallowing.
  Box<dynamic> box(String name) {
    final Box<dynamic>? found = _boxes[name];
    if (found == null) {
      throw StateError(
        'Box "$name" is not available. Call AppDatabase.init() during startup.',
      );
    }
    return found;
  }

  Box<dynamic>? maybeBox(String name) => _boxes[name];

  bool isBoxOpen(String name) => _boxes.containsKey(name);

  /// All documents of a box, normalised to JSON maps.
  List<Map<String, dynamic>> readAll(String boxName) {
    final Box<dynamic> store = box(boxName);
    return store.values
        .map<Map<String, dynamic>>((dynamic value) => JsonUtils.asMap(value))
        .where((Map<String, dynamic> value) => value.isNotEmpty)
        .toList();
  }

  Map<String, dynamic>? readOne(String boxName, String key) {
    final dynamic value = box(boxName).get(key);
    if (value == null) return null;
    final Map<String, dynamic> map = JsonUtils.asMap(value);
    return map.isEmpty ? null : map;
  }

  Future<void> writeOne(
    String boxName,
    String key,
    Map<String, dynamic> value,
  ) {
    return box(boxName).put(key, value);
  }

  Future<void> writeMany(
    String boxName,
    Map<String, Map<String, dynamic>> values,
  ) {
    return box(boxName).putAll(values);
  }

  Future<void> deleteOne(String boxName, String key) {
    return box(boxName).delete(key);
  }

  Future<void> clearBox(String boxName) {
    return box(boxName).clear();
  }

  /// Wipes user data while keeping the meta box (schema version, preferences).
  Future<void> clearUserData() async {
    for (final String name in DatabaseTables.userDataBoxes) {
      await clearBox(name);
    }
  }

  Future<void> close() async {
    for (final Box<dynamic> store in _boxes.values) {
      await store.close();
    }
    _boxes.clear();
    _initialized = false;
  }
}
