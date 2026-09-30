import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ProfileMenuSectionWidget extends StatelessWidget {
  final String title;
  final List<ProfileMenuItem> items;

  const ProfileMenuSectionWidget({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: items
                .map((item) => ProfileMenuItemWidget(item: item))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class ProfileMenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback? onTap;

  const ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.trailing,
    this.showChevron = true,
    this.onTap,
  });
}

class ProfileMenuItemWidget extends StatelessWidget {
  final ProfileMenuItem item;

  const ProfileMenuItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 0.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        item.subtitle,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.trailing != null)
                  item.trailing!
                else if (item.showChevron)
                  Icon(
                    Iconsax.arrow_right_3,
                    size: 16,
                    color: Theme.of(context).colorScheme.outline,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper class for creating common menu items
class ProfileMenuItems {
  static ProfileMenuItem createSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color switchColor,
  }) {
    return ProfileMenuItem(
      icon: icon,
      title: title,
      subtitle: subtitle,
      color: color,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: switchColor,
      ),
      showChevron: false,
      onTap: null,
    );
  }

  static ProfileMenuItem createCounterItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String count,
    Color? countColor,
    VoidCallback? onTap,
  }) {
    return ProfileMenuItem(
      icon: icon,
      title: title,
      subtitle: subtitle,
      color: color,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: (countColor ?? color).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          count,
          style:
              const TextStyle(
                fontFamily: 'outfit',
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ).copyWith(
                color: countColor ?? Theme.of(context).colorScheme.primary,
              ),
        ),
      ),
      onTap: onTap,
    );
  }

  static ProfileMenuItem createStatusItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String status,
    required IconData statusIcon,
    Color? statusColor,
    VoidCallback? onTap,
  }) {
    return ProfileMenuItem(
      icon: icon,
      title: title,
      subtitle: subtitle,
      color: color,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: (statusColor ?? color).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(statusIcon, size: 10, color: statusColor ?? color),
            const SizedBox(width: 4),
            Text(
              status,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 9,
                color: statusColor ?? Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
