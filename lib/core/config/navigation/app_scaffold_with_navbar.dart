import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class _TabMeta {
  final String? svgPath; // SVG icon path
  final IconData? icon; // Material icon (only for lekhan_ai AI)
  final String label;
  final bool isAI;
  const _TabMeta(
    this.label, {
    this.svgPath,
    this.icon,
    this.isAI = false,
  });
}

const _orange = Color(0xFFFF6B00);
const _inactive = Color(0xFF6B7280);

// 5 branches: index 0..4. The center (index 2) is the elevated "lekhan_ai AI" button.
const _tabs = [
  _TabMeta('Home', svgPath: 'assets/icons/home.svg'),
  _TabMeta('Projects', icon: Icons.library_books_outlined),
  _TabMeta('lekhan_ai AI', icon: Icons.smart_toy, isAI: true),
  _TabMeta('Bookings', svgPath: 'assets/icons/calendar.svg'),
  _TabMeta('Profile', svgPath: 'assets/icons/user.svg'),
];

class AppScaffoldWithNavbar extends StatelessWidget {
  const AppScaffoldWithNavbar({required this.appNavigationShell, Key? key})
      : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));
  final StatefulNavigationShell appNavigationShell;

  @override
  Widget build(BuildContext context) {
    final currentIndex = appNavigationShell.currentIndex;

    return Scaffold(
      backgroundColor: const Color(0xFFE5F0FD),
      extendBody: true,
      body: appNavigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (i) {
                if (i == 2) {
                  return _CenterNavItem(
                    tab: _tabs[i],
                    isSelected: currentIndex == i,
                    onTap: () => _onTap(context, i),
                  );
                }
                return _NavItem(
                  tab: _tabs[i],
                  isSelected: currentIndex == i,
                  onTap: () => _onTap(context, i),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    appNavigationShell.goBranch(
      index,
      initialLocation: index == appNavigationShell.currentIndex,
    );
  }
}

class _NavItem extends StatelessWidget {
  final _TabMeta tab;
  final bool isSelected;
  final VoidCallback onTap;
  const _NavItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? _orange : _inactive;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (tab.svgPath != null)
              SvgPicture.asset(
                tab.svgPath!,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              )
            else if (tab.icon != null)
              Icon(tab.icon, size: 20, color: color),
            const SizedBox(height: 2),
            Text(
              tab.label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: color,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterNavItem extends StatelessWidget {
  final _TabMeta tab;
  final bool isSelected;
  final VoidCallback onTap;
  const _CenterNavItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: _orange,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _orange.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.smart_toy,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -16),
              child: Text(
                tab.label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _orange,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
