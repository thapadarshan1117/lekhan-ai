import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/features/sync/presentation/bloc/sync_bloc.dart';

/// Widget that displays current sync status: pending, in-progress, completed tasks.
class SyncStatusWidget extends StatelessWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncBloc, SyncState>(
      builder: (BuildContext context, SyncState state) {
        return state.maybeWhen(
          loaded: (stats) {
            // Show nothing if idle
            if (stats.isIdle && stats.failed == 0) {
              return const SizedBox.shrink();
            }

            // Determine status color and icon
            final bool hasFailed = stats.failed > 0;
            final bool isInProgress = stats.inProgress > 0;
            final Color statusColor = hasFailed
                ? Colors.red
                : isInProgress
                    ? AppColors.primary
                    : Colors.green;

            final String statusText = hasFailed
                ? '${stats.failed} failed'
                : isInProgress
                    ? 'Syncing... (${stats.inProgress})'
                    : 'All synced!';

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: isInProgress
                        ? SizedBox.expand(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                            ),
                          )
                        : Icon(
                            hasFailed ? Icons.error_outline : Icons.check_circle,
                            size: 14,
                            color: statusColor,
                          ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }
}
