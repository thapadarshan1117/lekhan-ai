import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lekhan_ai/core/config/dependency_injection/di_config.dart';
import 'package:lekhan_ai/core/enums/sync_operation.dart';
import 'package:lekhan_ai/core/sync/sync_task.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/features/sync/domain/usecases/get_sync_status_usecase.dart';
import 'package:lekhan_ai/features/sync/domain/usecases/retry_sync_usecase.dart';
import 'package:lekhan_ai/features/sync/presentation/bloc/sync_status_cubit.dart';

/// The sync centre: what is still on the device, and why.
///
/// Nothing here is needed for data to be safe - it exists so the user can see
/// that unsent work is tracked rather than lost.
class SyncCentrePage extends StatefulWidget {
  const SyncCentrePage({super.key});

  @override
  State<SyncCentrePage> createState() => _SyncCentrePageState();
}

class _SyncCentrePageState extends State<SyncCentrePage> {
  List<SyncTask> _pending = const <SyncTask>[];
  List<SyncTask> _failed = const <SyncTask>[];
  bool _loading = true;
  DateTime? _lastSyncedAt;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final GetSyncStatusUsecase status = sl<GetSyncStatusUsecase>();

    final List<SyncTask> pending = await status.pending();
    final List<SyncTask> failed = await status.failed();
    final DateTime? lastSynced = await status.lastSyncedAt();

    if (!mounted) return;
    setState(() {
      _pending = pending;
      _failed = failed;
      _lastSyncedAt = lastSynced;
      _loading = false;
    });
  }

  Future<void> _retryAll() async {
    await sl<RetrySyncUsecase>()(const RetrySyncParams(resetAttempts: true));
    await _load();
  }

  Future<void> _retryOne(String taskId) async {
    await sl<RetrySingleTaskUsecase>()(taskId);
    await _load();
  }

  Future<void> _cancelOne(String taskId) async {
    await sl<CancelSyncTaskUsecase>()(taskId);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Sync centre',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: <Widget>[
                  _StatusCard(lastSyncedAt: _lastSyncedAt),
                  const SizedBox(height: 20),
                  if (_failed.isNotEmpty) ...<Widget>[
                    Row(
                      children: <Widget>[
                        const Expanded(
                          child: Text(
                            'Needs attention',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _retryAll,
                          child: const Text('Retry all'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ..._failed.map(
                      (SyncTask task) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TaskTile(
                          task: task,
                          failed: true,
                          onRetry: () => _retryOne(task.id),
                          onCancel: () => _cancelOne(task.id),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Text(
                    'Waiting to upload',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_pending.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'Nothing is waiting. Everything on this device has been '
                        'sent.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  else
                    ..._pending.map(
                      (SyncTask task) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TaskTile(task: task, failed: false),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.lastSyncedAt});

  final DateTime? lastSyncedAt;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SyncStatusCubit>(
      create: (BuildContext context) => sl<SyncStatusCubit>()..start(),
      child: BlocBuilder<SyncStatusCubit, SyncStatusState>(
        builder: (BuildContext context, SyncStatusState state) {
          final String headline = state.isSyncing
              ? 'Syncing now'
              : state.hasFailures
                  ? '${state.failedCount} item(s) need attention'
                  : state.hasPending
                      ? '${state.pendingCount} item(s) waiting to upload'
                      : 'Everything is saved';

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      state.hasFailures
                          ? Icons.error_outline
                          : state.hasPending
                              ? Icons.cloud_upload_outlined
                              : Icons.cloud_done_outlined,
                      size: 20,
                      color: state.hasFailures
                          ? AppColors.error
                          : state.hasPending
                              ? AppColors.secondary
                              : const Color(0xFF1B7F4B),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        headline,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  lastSyncedAt == null
                      ? 'Never synced yet.'
                      : 'Last successful sync: ${_format(lastSyncedAt!)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context
                            .read<SyncStatusCubit>()
                            .syncNow(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 42),
                        ),
                        child: const Text('Sync now'),
                      ),
                    ),
                    if (state.hasFailures) ...<Widget>[
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => context
                              .read<SyncStatusCubit>()
                              .retryFailed(),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 42),
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Retry failed'),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static String _format(DateTime value) {
    final String two = value.minute.toString().padLeft(2, '0');
    return '${value.day}/${value.month}/${value.year} '
        '${value.hour}:$two';
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.failed,
    this.onRetry,
    this.onCancel,
  });

  final SyncTask task;
  final bool failed;
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final String title =
        '${_label(task.entityType)} · ${_operationLabel(task.operation)}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (failed ? AppColors.error : AppColors.secondary)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  failed ? 'Failed' : 'Queued',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: failed ? AppColors.error : AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          if (task.isUpload && task.progress != null && !failed) ...<Widget>[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: task.progress!.clamp(0, 1).toDouble(),
                minHeight: 5,
                backgroundColor: AppColors.surfaceVariant,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
          if (failed && task.errorMessage != null) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              task.errorMessage!,
              style: const TextStyle(fontSize: 12, color: AppColors.error),
            ),
            const SizedBox(height: 2),
            Text(
              'Attempt ${task.attemptCount} of ${task.maxAttempts}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (failed && onRetry != null) ...<Widget>[
            const SizedBox(height: 6),
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: onRetry,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 34),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text('Retry', style: TextStyle(fontSize: 13)),
                ),
                if (onCancel != null)
                  TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, 34),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      foregroundColor: AppColors.textSecondary,
                    ),
                    child: const Text(
                      'Discard',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static String _label(SyncEntityType type) {
    switch (type) {
      case SyncEntityType.project:
        return 'Project';
      case SyncEntityType.book:
        return 'Book';
      case SyncEntityType.chapter:
        return 'Chapter';
      case SyncEntityType.chapterSource:
        return 'Source file';
      case SyncEntityType.uploadSession:
        return 'Upload';
      case SyncEntityType.progress:
        return 'Writing progress';
    }
  }

  static String _operationLabel(SyncOperation operation) {
    switch (operation) {
      case SyncOperation.create:
        return 'create';
      case SyncOperation.update:
        return 'update';
      case SyncOperation.delete:
        return 'delete';
      case SyncOperation.uploadFile:
        return 'upload';
      case SyncOperation.pullMetadata:
        return 'download';
    }
  }
}
