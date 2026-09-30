import 'dart:developer';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:lekhan_ai/core/constants/storage_constants.dart';
import 'package:lekhan_ai/core/utils/json_utils.dart';

/// Forward-only migrations for the local store.
///
/// Hive itself is schemaless, so a "migration" here means backfilling or
/// repairing documents after the Dart models changed shape. Every step must be
/// idempotent: it may run again after an interrupted upgrade.
class DatabaseMigrations {
  DatabaseMigrations({required this.metaBox});

  final Box<dynamic> metaBox;

  /// Bump this whenever the on-device document shape changes.
  static const int currentVersion = 1;

  Future<void> run() async {
    final int stored = JsonUtils.asInt(
      metaBox.get(StorageConstants.schemaVersionKey),
      0,
    );

    if (stored >= currentVersion) return;

    log('DatabaseMigrations: upgrading local store v$stored -> v$currentVersion');

    if (stored < 1) {
      await _toVersion1();
    }

    await metaBox.put(StorageConstants.schemaVersionKey, currentVersion);
    log('DatabaseMigrations: local store is at v$currentVersion');
  }

  /// v1 - baseline. Nothing to transform, only the version bookkeeping.
  Future<void> _toVersion1() async {
    await metaBox.put(StorageConstants.schemaVersionKey, 1);
  }
}
