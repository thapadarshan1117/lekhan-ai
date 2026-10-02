import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lekhan_ai/core/config/dependency_injection/di_config.dart';
import 'package:lekhan_ai/core/enums/sync_operation.dart';
import 'package:lekhan_ai/core/sync/sync_task.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/features/sync/domain/usecases/get_sync_status_usecase.dart';
import 'package:lekhan_ai/features/sync/domain/usecases/retry_sync_usecase.dart';
import 'package:lekhan_ai/features/sync/presentation/bloc/sync_status_cubit.dart';
import 'package:lekhan_ai/l10n/l10n.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          context.l10n.backupStatus,
          style: TextStyle(
            fontSize: 21,
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
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Text(
                          context.l10n.needsAttention,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: _retryAll,
                          child: Text(context.l10n.tryAllAgain),
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
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    context.l10n.waitingForBackup,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_pending.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        context.l10n.nothingWaiting,
                        style: const TextStyle(
                          fontSize: 16,
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
              ? context.l10n.saving
              : state.hasFailures
                  ? context.l10n.itemsNeedAttention(state.failedCount)
                  : state.hasPending
                      ? context.l10n.itemsWaitingBackup(state.pendingCount)
                      : context.l10n.everythingSaved;

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
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  lastSyncedAt == null
                      ? context.l10n.noOnlineCopyYet
                      : context.l10n.lastBackup(
                          _format(context, lastSyncedAt!),
                        ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () =>
                      context.read<SyncStatusCubit>().syncNow(),
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: Text(context.l10n.backupNow),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                ),
                if (state.hasFailures) ...<Widget>[
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () =>
                        context.read<SyncStatusCubit>().retryFailed(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(context.l10n.retryFailed),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  static String _format(BuildContext context, DateTime value) {
    final MaterialLocalizations material = MaterialLocalizations.of(context);
    final String date = material.formatShortDate(value);
    final String time = material.formatTimeOfDay(
      TimeOfDay.fromDateTime(value),
    );
    return '$date, $time';
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.failed,
    this.onRetry,
  });

  final SyncTask task;
  final bool failed;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final String title =
        '${_label(context, task.entityType)} · '
        '${_operationLabel(context, task.operation)}';

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
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: (failed ? AppColors.error : AppColors.secondary)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  failed ? context.l10n.taskNeedsHelp : context.l10n.taskWaiting,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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
                minHeight: 9,
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
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              context.l10n.attemptCount(task.attemptCount),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (failed && onRetry != null) ...<Widget>[
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.retry),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 52),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _label(BuildContext context, SyncEntityType type) {
    switch (type) {
      case SyncEntityType.project:
        return context.l10n.taskProject;
      case SyncEntityType.book:
        return context.l10n.taskBook;
      case SyncEntityType.chapter:
        return context.l10n.taskChapter;
      case SyncEntityType.chapterSource:
        return context.l10n.taskSource;
      case SyncEntityType.uploadSession:
        return context.l10n.taskBackup;
      case SyncEntityType.progress:
        return context.l10n.taskProgress;
    }
  }

  static String _operationLabel(
    BuildContext context,
    SyncOperation operation,
  ) {
    switch (operation) {
      case SyncOperation.create:
        return context.l10n.taskCreate;
      case SyncOperation.update:
        return context.l10n.taskUpdate;
      case SyncOperation.delete:
        return context.l10n.taskDelete;
      case SyncOperation.uploadFile:
        return context.l10n.taskUpload;
      case SyncOperation.pullMetadata:
        return context.l10n.taskDownload;
    }
  }
}
