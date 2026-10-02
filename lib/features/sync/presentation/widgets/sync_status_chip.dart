import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lekhan_ai/core/config/dependency_injection/di_config.dart';
import 'package:lekhan_ai/core/enums/sync_status.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/features/sync/presentation/bloc/sync_status_cubit.dart';
import 'package:lekhan_ai/l10n/l10n.dart';

/// The small indicator in the app bar.
///
/// It answers one question honestly: "is everything on the server yet?" - and
/// makes it obvious that unsent work is normal, not broken.
class SyncStatusChip extends StatelessWidget {
  const SyncStatusChip({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SyncStatusCubit>(
      create: (BuildContext context) => sl<SyncStatusCubit>()..start(),
      child: const _SyncStatusChipView(),
    );
  }
}

class _SyncStatusChipView extends StatelessWidget {
  const _SyncStatusChipView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncStatusCubit, SyncStatusState>(
      builder: (BuildContext context, SyncStatusState state) {
        final _ChipVisuals visuals = _visualsFor(context, state);

        return Semantics(
          button: true,
          label: '${context.l10n.backupStatus}: ${visuals.label}',
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => context.pushNamed('syncCentre'),
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: visuals.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: visuals.color.withValues(alpha: 0.24),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (state.isSyncing)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: visuals.color,
                      ),
                    )
                  else
                    Icon(visuals.icon, size: 21, color: visuals.color),
                  const SizedBox(width: 8),
                  Text(
                    visuals.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: visuals.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static _ChipVisuals _visualsFor(
    BuildContext context,
    SyncStatusState state,
  ) {
    if (state.isSyncing) {
      return _ChipVisuals(
        label: context.l10n.saving,
        icon: Icons.sync,
        color: AppColors.primary,
      );
    }

    if (state.hasFailures) {
      return _ChipVisuals(
        label: context.l10n.backupIssue,
        icon: Icons.error_outline,
        color: AppColors.error,
      );
    }

    if (state.status == SyncConnectionStatus.offline) {
      return _ChipVisuals(
        label: state.hasPending
            ? context.l10n.countWaiting(state.pendingCount)
            : context.l10n.offline,
        icon: Icons.cloud_off_outlined,
        color: AppColors.textSecondary,
      );
    }

    if (state.hasPending) {
      return _ChipVisuals(
        label: context.l10n.countWaiting(state.pendingCount),
        icon: Icons.cloud_upload_outlined,
        color: AppColors.secondary,
      );
    }

    if (state.status == SyncConnectionStatus.synced) {
      return _ChipVisuals(
        label: context.l10n.allSaved,
        icon: Icons.cloud_done_outlined,
        color: const Color(0xFF1B7F4B),
      );
    }

    return _ChipVisuals(
      label: context.l10n.upToDate,
      icon: Icons.cloud_queue,
      color: AppColors.textSecondary,
    );
  }
}

class _ChipVisuals {
  const _ChipVisuals({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}
