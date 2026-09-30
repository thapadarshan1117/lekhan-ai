import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import 'profile_menu_section_widget.dart';

class SecuritySectionWidget extends StatelessWidget {
  const SecuritySectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileMenuSectionWidget(
      title: 'Security & Privacy',
      items: [
        ProfileMenuItem(
          icon: Iconsax.lock,
          title: 'Change Password',
          subtitle: 'Update your password regularly',
          color: Theme.of(context).colorScheme.secondary,
          onTap: () => context.push('/profile/change-password'),
        ),
        ProfileMenuItem(
          icon: Iconsax.shield,
          title: 'Data Privacy',
          subtitle: 'Manage your medical data sharing',
          color: Theme.of(context).colorScheme.primary,
          onTap: () => context.push('/profile/privacy-settings'),
        ),
      ],
    );
  }
}
