import 'package:lekhan_ai/core/database/database_tables.dart';
import 'package:lekhan_ai/core/utils/json_utils.dart';

/// Outcome of comparing the local copy of a record with the server's copy.
enum ConflictDecision {
  /// Nothing changed on either side.
  noChange,

  /// The server is newer (or the local copy is clean): take the server value.
  takeRemote,

  /// The local copy has unsent changes and is newer: keep it and push.
  keepLocalAndPush,

  /// The local copy has unsent changes but the server is newer: keep the local
  /// edit (never silently destroy a user's words) and let the push decide.
  keepLocalAndPushConflict,

  /// The record was deleted remotely and has no local changes: delete locally.
  deleteLocal,
}

/// Which rule the conflict was resolved with. Store it for support/debugging.
enum ConflictResolution {
  remoteWins('remote_wins'),
  localWins('local_wins'),
  localWinsConflict('local_wins_conflict'),
  noChange('no_change'),
  remoteDeleted('remote_deleted');

  const ConflictResolution(this.value);

  final String value;

  static ConflictResolution fromString(String? raw) {
    if (raw == null) return ConflictResolution.noChange;
    final String needle = raw.trim().toLowerCase();
    for (final ConflictResolution value in ConflictResolution.values) {
      if (value.value == needle) return value;
    }
    return ConflictResolution.noChange;
  }
}

/// Result of resolving one record.
class ConflictResult {
  const ConflictResult({
    required this.decision,
    required this.resolution,
    this.reason,
  });

  final ConflictDecision decision;
  final ConflictResolution resolution;
  final String? reason;

  bool get shouldApplyRemote => decision == ConflictDecision.takeRemote;

  bool get shouldDeleteLocal => decision == ConflictDecision.deleteLocal;

  bool get shouldPushLocal => decision == ConflictDecision.keepLocalAndPush ||
      decision == ConflictDecision.keepLocalAndPushConflict;
}

/// Conflict policy for the offline store, in one place.
///
/// The rules are intentionally biased towards *never losing user work*:
///
///  * No local changes (clean record) -> the server always wins. That is what
///    makes a fresh login or a reinstall pick up whatever happened elsewhere.
///  * Local changes, local copy older -> the server wins, because someone else
///    finished the work later. The local edit is dropped, but only because it
///    was already superseded and there were no unsent bytes.
///  * Local changes, local copy newer -> the local copy wins and is pushed.
///  * Both changed, timestamps too close to call -> the local copy wins and is
///    pushed, and the push response decides the final state.
///
/// Files are never merged: a source is an immutable record, so two recordings
/// become two sources instead of overwriting each other.
class ConflictResolver {
  const ConflictResolver({this.tieBreakWindow = const Duration(seconds: 90)});

  /// When the two timestamps are this close, we refuse to guess.
  final Duration tieBreakWindow;

  ConflictResult resolve({
    required Map<String, dynamic> local,
    required Map<String, dynamic> remote,
  }) {
    final bool remoteDeleted = JsonUtils.asBool(
      remote[DatabaseTables.fieldIsDeleted],
    );
    final bool localDirty = JsonUtils.asBool(
      local[DatabaseTables.fieldIsDirty],
    );

    final DateTime localUpdated = JsonUtils.asDateTime(
          local[DatabaseTables.fieldUpdatedAt],
        ) ??
        DateTime.fromMillisecondsSinceEpoch(0);
    final DateTime remoteUpdated = JsonUtils.asDateTime(
          remote[DatabaseTables.fieldUpdatedAt],
        ) ??
        localUpdated;

    if (remoteDeleted) {
      if (localDirty) {
        return const ConflictResult(
          decision: ConflictDecision.keepLocalAndPushConflict,
          resolution: ConflictResolution.localWinsConflict,
          reason: 'Remote delete vs local edit: the local edit is preserved.',
        );
      }
      return const ConflictResult(
        decision: ConflictDecision.deleteLocal,
        resolution: ConflictResolution.remoteDeleted,
        reason: 'Record was deleted on the server.',
      );
    }

    if (!localDirty) {
      if (remoteUpdated.isAfter(localUpdated)) {
        return const ConflictResult(
          decision: ConflictDecision.takeRemote,
          resolution: ConflictResolution.remoteWins,
          reason: 'Local copy is clean; taking the newer server copy.',
        );
      }
      return const ConflictResult(
        decision: ConflictDecision.noChange,
        resolution: ConflictResolution.noChange,
      );
    }

    final Duration skew = localUpdated.difference(remoteUpdated).abs();
    if (skew <= tieBreakWindow) {
      return const ConflictResult(
        decision: ConflictDecision.keepLocalAndPushConflict,
        resolution: ConflictResolution.localWinsConflict,
        reason: 'Changes are too close to call; keeping the local edit.',
      );
    }

    if (localUpdated.isAfter(remoteUpdated)) {
      return const ConflictResult(
        decision: ConflictDecision.keepLocalAndPush,
        resolution: ConflictResolution.localWins,
        reason: 'Local edit is newer and unsent.',
      );
    }

    return const ConflictResult(
      decision: ConflictDecision.takeRemote,
      resolution: ConflictResolution.remoteWins,
      reason: 'Server copy is newer than the local edit.',
    );
  }
}
