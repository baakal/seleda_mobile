import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Custom bottom navigation that reserves the center spot for the expanding FAB
/// (see `ExpandableFab`). We therefore arrange two items on the left and two
/// on the right of the notch. Index mapping is preserved to match the router's
/// calculated index values (0..4) although visually index 2 (search) is to the
/// right of the notch.
class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({super.key, required this.currentIndex});

  final int currentIndex;

  void _onTap(BuildContext context, int originalIndex) {
    switch (originalIndex) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/categories');
        break;
      case 2:
        context.go('/search');
        break;
      case 3:
        context.go('/reports');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }

  Color _iconColor(BuildContext context, int index) {
    final selected = index == currentIndex;
    return selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Left side (indices 0,1)
            _NavItem(
              label: 'Home',
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              color: _iconColor(context, 0),
              selected: currentIndex == 0,
              onTap: () => _onTap(context, 0),
            ),
            _NavItem(
              label: 'Categories',
              icon: Icons.category_outlined,
              selectedIcon: Icons.category,
              color: _iconColor(context, 1),
              selected: currentIndex == 1,
              onTap: () => _onTap(context, 1),
            ),
            const SizedBox(width: 56), // Space for FAB diameter
            _NavItem(
              label: 'Search',
              icon: Icons.search_outlined,
              selectedIcon: Icons.search,
              color: _iconColor(context, 2),
              selected: currentIndex == 2,
              onTap: () => _onTap(context, 2),
            ),
            _NavItem(
              label: 'Reports',
              icon: Icons.pie_chart_outline,
              selectedIcon: Icons.pie_chart,
              color: _iconColor(context, 3),
              selected: currentIndex == 3,
              onTap: () => _onTap(context, 3),
            ),
            _NavItem(
              label: 'Settings',
              icon: Icons.settings_outlined,
              selectedIcon: Icons.settings,
              color: _iconColor(context, 4),
              selected: currentIndex == 4,
              onTap: () => _onTap(context, 4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? selectedIcon : icon, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
