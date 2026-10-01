import 'package:lekhan_ai/core/router/route_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lekhan_ai/features/profile/pages/favorites_page.dart';
import 'package:lekhan_ai/features/profile/pages/address_page.dart';

class ProfileMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Static profile data
  static const String userName = 'John Doe';
  static const String userPhoneNumber = '+977 9841234567';
  static const String userAvatarUrl = 'https://img.magnific.com/free-photo/image-young-asian-woman-company-worker-glasses-smiling-holding-digital-tablet-standing-white-background_1258-89376.jpg?semt=ais_hybrid&w=740&q=80/';
  static const bool userIsVerified = true;

  void _handleEditProfile() {
    // Placeholder for future navigation to edit-profile page
    // context.push(RouterManager.rEditProfile);
  }

  void _handleFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FavoritesPage()),
    );
  }

  void _handleAddress() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddressPage()),
    );
  }

  void _handleNotification() {
    // Placeholder for future navigation to notification settings
    // context.push('notifications');
  }


  void _handleHelpCenter() {
    // Placeholder for future navigation to help center
    context.push('/help-center');
  }


  void _handleTermsAndPolicy() {
    // Placeholder for future navigation to terms & policy page
    context.push('/terms-policy');
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log out?'),
          content: const Text('Are you sure you want to log out of your account?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Log out', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Placeholder for future logout logic (clear session, tokens, etc.)
      // context.go('login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final menuItems = [
      ProfileMenuItem(icon: Iconsax.user, label: 'Edit Profile', onTap: _handleEditProfile),
      ProfileMenuItem(icon: Iconsax.heart, label: 'Favorites', onTap: _handleFavorites),
      ProfileMenuItem(icon: Iconsax.location, label: 'Address', onTap: _handleAddress),
      ProfileMenuItem(icon: Iconsax.notification, label: 'Notification', onTap: _handleNotification),
      ProfileMenuItem(icon: Iconsax.headphone, label: 'Help Center', onTap: _handleHelpCenter),
      ProfileMenuItem(icon: Iconsax.document, label: 'Terms & Policy', onTap: _handleTermsAndPolicy),
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Profile',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ===== AVATAR / NAME / PHONE =====
          Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipOval(
                    child: Image.network(
                      userAvatarUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 100,
                        height: 100,
                        color: colorScheme.secondary.withValues(alpha: 0.1),
                        child: Icon(Iconsax.user, size: 40, color: colorScheme.secondary),
                      ),
                    ),
                  ),
                  if (userIsVerified)
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Icon(Icons.verified, size: 22, color: Colors.blue),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                userName,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userPhoneNumber,
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
            ],
          ),
          Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.15)),

          // ===== MENU ITEMS =====
          ...menuItems.map((item) {
            return _ProfileMenuTile(
              item: item,
              colorScheme: colorScheme,
              textTheme: textTheme,
            );
          }),

          const SizedBox(height: 4),
          _ProfileMenuTile(
            item: ProfileMenuItem(
              icon: Iconsax.logout,
              label: 'Logout',
              onTap: _handleLogout,
              isDestructive: true,
            ),
            colorScheme: colorScheme,
            textTheme: textTheme,
            showChevron: false,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ============= REUSABLE PIECES =============

class _ProfileMenuTile extends StatelessWidget {
  final ProfileMenuItem item;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final bool showChevron;

  const _ProfileMenuTile({
    required this.item,
    required this.colorScheme,
    required this.textTheme,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = item.isDestructive ? Colors.red.shade600 : colorScheme.onSurface;

    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(item.icon, size: 20, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.label,
                style: textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (showChevron)
              Icon(Icons.chevron_right, size: 20, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
