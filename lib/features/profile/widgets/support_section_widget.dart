import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';

import 'profile_menu_section_widget.dart';

class SupportSectionWidget extends StatelessWidget {
  const SupportSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileMenuSectionWidget(
      title: 'Resources & Support',
      items: [
    
        ProfileMenuItem(
          icon: Iconsax.people,
          title: 'Customer',
          subtitle: 'Get in touch with customer',
          color: Theme.of(context).colorScheme.secondary,
          onTap: () => context.push('/lead'),
        ),

            ProfileMenuItem(
          icon: Iconsax.people,
          title: 'Analytics',
          subtitle: 'View your performance analytics',
          color: Theme.of(context).colorScheme.secondary,
          onTap: () => context.push('/analytics'),
        ),
      
      ],
    );
  }
}
