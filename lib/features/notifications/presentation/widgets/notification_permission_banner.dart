import 'package:lekhan_ai/features/notifications/presentation/bloc/notification_permission_cubit.dart';
import 'package:lekhan_ai/features/notifications/presentation/bloc/notification_permission_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lekhan_ai/core/utils/haptic.dart';

class NotificationPermissionBanner extends StatelessWidget {
  final String message;
  final EdgeInsets padding;
  final Duration promptCooldown;

  const NotificationPermissionBanner({
    super.key,
    this.message = 'System notifications are off. Enable to receive updates.',
    this.padding = const EdgeInsets.all(12),
    this.promptCooldown = const Duration(hours: 24),
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationPermissionCubit,
        NotificationPermissionState>(
      builder: (context, state) {
        bool show = true;
        if (state is NotificationPermissionStatus && state.authorized) {
          show = false;
        } else if (state is NotificationPermissionAuthorized) {
          show = false;
        } else if (state is NotificationPermissionError) {
          show = true; // still show on error
        }

        if (!show) return const SizedBox.shrink();

        final cubit = context.read<NotificationPermissionCubit>();
        if (!cubit.shouldPromptAgain(cooldown: promptCooldown)) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.amber.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.shade300),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.notifications_off_outlined, color: Colors.amber),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () async {
                  HapticUtils.medium();
                  // Try to show OS permission dialog first (no prompt cooldown yet)
                  await cubit.requestAndRegisterToken();

                  // Check if permission is now granted
                  var st = cubit.state;
                  var authorized = st is NotificationPermissionAuthorized ||
                      (st is NotificationPermissionStatus && st.authorized);

                  if (!authorized) {
                    // Open system settings (Android -> Notifications page, iOS -> App settings)
                    await cubit.openSystemSettingsAndRetry();

                    // Re-check status after returning from settings
                    await cubit.checkStatus();
                    st = cubit.state;
                    authorized = st is NotificationPermissionAuthorized ||
                        (st is NotificationPermissionStatus && st.authorized);
                  }

                  // On Android, guide user to disable battery optimizations (Redmi/MIUI)
                  if (authorized) {
                    await cubit.openBatteryOptimizationSettings();
                    // Also run a silent sync to ensure reminders are scheduled
                    await cubit.autoSync();
                  }

                  // Mark prompt shown only if the user granted permission; otherwise keep banner visible
                  if (authorized) {
                    cubit.markPromptShown();
                  }
                },
                child: const Text('Enable'),
              ),
            ],
          ),
        );
      },
    );
  }
}
