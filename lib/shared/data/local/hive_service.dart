import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:lekhan_ai/shared/data/local/storage_service.dart';

class HiveService implements StorageService {
  Box? _box;

  final Completer<void> _initCompleter = Completer<void>();

  @override
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('sahara_app_storageBox');
    _initCompleter.complete();
  }

  @override
  bool get hasInitialized => _box != null;

  @override
  Future<Object?> get(String key) async {
    await _initCompleter.future;
    return _box?.get(key);
  }

  @override
  Future<void> clear() async {
    await _initCompleter.future;
    await _box?.clear();
  }

  @override
  Future<bool> has(String key) async {
    await _initCompleter.future;
    return _box?.containsKey(key) ?? false;
  }

  @override
  Future<bool> remove(String key) async {
    await _initCompleter.future;
    await _box?.delete(key);
    return true;
  }

  @override
  Future<bool> set(String key, data) async {
    await _initCompleter.future;
    await _box?.put(key, data);
    return true;
  }
}