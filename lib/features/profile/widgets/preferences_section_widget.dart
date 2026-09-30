import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'profile_menu_section_widget.dart';

class PreferencesSectionWidget extends StatelessWidget {
  final bool notificationsEnabled;
  final bool smsEnabled;
  final bool emailEnabled;
  final ValueChanged<bool> onNotificationsChanged;
  final ValueChanged<bool> onSmsChanged;
  final ValueChanged<bool> onEmailChanged;

  const PreferencesSectionWidget({
    super.key,
    required this.notificationsEnabled,
    required this.smsEnabled,
    required this.emailEnabled,
    required this.onNotificationsChanged,
    required this.onSmsChanged,
    required this.onEmailChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ProfileMenuSectionWidget(
      title: 'Health & Notifications',
      items: [
        ProfileMenuItems.createSwitchItem(
          icon: Iconsax.notification,
          title: 'Appointment Reminders',
          subtitle: 'Test & consultation reminders',
          color: theme.colorScheme.primary,
          value: notificationsEnabled,
          switchColor: theme.colorScheme.primary,
          onChanged: onNotificationsChanged,
        ),
        
        ProfileMenuItem(
          icon: Iconsax.health,
          title: 'Emergency Contacts',
          subtitle: 'Manage emergency contacts',
          color: theme.colorScheme.error,
          onTap: () {},
        ),
        ProfileMenuItem(
          icon: Iconsax.document_text,
          title: 'Medical History',
          subtitle: 'View & update records',
          color: theme.colorScheme.outline,
          onTap: () {},
        ),
      ],
    );
  }
}
