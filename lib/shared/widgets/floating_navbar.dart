import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/route_constants.dart';
import '../../core/theme/app_colors.dart';

class FloatingNavbar extends StatelessWidget {
  final String activeRoute;

  const FloatingNavbar({
    super.key,
    required this.activeRoute,
  });

  @override
  Widget build(BuildContext context) {
    // A premium, pill-shaped floating navbar inspired by the user's reference
    return Container(
      color: Colors.transparent, // Ensure the background of the bottomNavigationBar slot is transparent
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(
              icon: Icons.dashboard_rounded,
              active: activeRoute == Routes.dashboard,
              onTap: () => _navigate(context, Routes.dashboard),
            ),
            _NavItem(
              icon: Icons.notifications_active_rounded,
              active: activeRoute == Routes.reminder,
              onTap: () => _navigate(context, Routes.reminder),
            ),
            _NavItem(
              icon: Icons.history_rounded,
              active: activeRoute == Routes.history,
              onTap: () => _navigate(context, Routes.history),
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    if (activeRoute != route) {
      context.go(route);
    }
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1A1C1E) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: active ? Colors.white : Colors.black45,
          size: 26,
        ),
      ),
    );
  }
}
