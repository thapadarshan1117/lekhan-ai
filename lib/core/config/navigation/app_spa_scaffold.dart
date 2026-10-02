import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class _TabMeta {
  final IconData icon;
  final String label;
  final String route;

  const _TabMeta({
    required this.icon,
    required this.label,
    required this.route,
  });
}

const _primary = Color(0xFF176B45);
const _success = Color(0xFF10B981);
const _inactive = Color(0xFF6B7280);

/// 3 essential tabs for data-focused SPA: Collect | Upload Status | Settings
const _tabs = [
  _TabMeta(icon: Icons.add_circle_outline, label: 'Collect', route: '/home'),
  _TabMeta(icon: Icons.cloud_upload_outlined, label: 'Uploads', route: '/sync'),
  _TabMeta(icon: Icons.settings_outlined, label: 'Settings', route: '/profile'),
];

/// Data Collection & Upload Focused Single Page Application (SPA) Scaffold
/// 
/// Purpose: Simplified, single-page app for collecting and uploading data
/// - Minimal navigation (3 tabs only)
/// - No projects/books/chapters complexity
/// - Focus: capture → upload → confirm
/// 
/// Tabs:
/// 1. COLLECT: Record/upload source material
/// 2. UPLOADS: View upload queue and status
/// 3. SETTINGS: User profile and preferences
class AppSpaScaffold extends StatelessWidget {
  const AppSpaScaffold({required this.shell, Key? key}) : super(key: key);

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final currentIndex = shell.currentIndex;
    final tabLabel = _tabs[currentIndex].label;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: _buildAppBar(context, currentIndex, tabLabel),
      body: shell,
      bottomNavigationBar: _buildBottomNav(context, currentIndex),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    int currentIndex,
    String tabLabel,
  ) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Container(
            width: 8,
            height: 24,
            decoration: BoxDecoration(
              color: currentIndex == 0 ? _primary : _success,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tabLabel,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF191c1f),
                ),
              ),
              Text(
                'Data Collection & Upload',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: _inactive,
                ),
              ),
            ],
          ),
        ],
      ),
      centerTitle: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Badge(
              label: const Text('3'),
              backgroundColor: _primary,
              child: const Icon(Icons.notifications_none, color: Color(0xFF191c1f)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context, int currentIndex) {
    return SafeArea(
      top: false,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
            // Subtle shadow effect
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_tabs.length, (i) {
            return _SpaNavItem(
              tab: _tabs[i],
              isSelected: currentIndex == i,
              onTap: () => _onTap(context, i),
            );
          }),
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    shell.goBranch(
      index,
      initialLocation: index == shell.currentIndex,
    );
  }
}

class _SpaNavItem extends StatefulWidget {
  final _TabMeta tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _SpaNavItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SpaNavItem> createState() => _SpaNavItemState();
}

class _SpaNavItemState extends State<_SpaNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    if (widget.isSelected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_SpaNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward();
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isSelected ? _primary : _inactive;
    final scale = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    return Expanded(
      child: InkWell(
        onTap: widget.onTap,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: ScaleTransition(
          scale: scale,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: widget.isSelected
                    ? BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      )
                    : null,
                child: Icon(
                  widget.tab.icon,
                  size: 24,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.tab.label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight:
                      widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.isSelected)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
