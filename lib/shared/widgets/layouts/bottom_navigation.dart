import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_spacing.dart';
import 'package:blithepay/core/constants/app_typography.dart';
import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:blithepay/shared/widgets/layouts/spacing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavigationWidget extends StatelessWidget {
  final String currentRoute;

  const BottomNavigationWidget({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex();

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 0,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      currentIndex: currentIndex,
      onTap: (index) => _navigate(context, index),
      items: [
        _buildItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Home',
          isActive: currentIndex == 0,
        ),
        _buildItem(
          icon: Icons.grid_view,
          activeIcon: Icons.grid_view,
          label: 'Services',
          isActive: currentIndex == 1,
        ),
        _buildItem(
          icon: Icons.receipt,
          activeIcon: Icons.receipt,
          label: 'Transactions',
          isActive: currentIndex == 2,
        ),
        _buildItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Profile',
          isActive: currentIndex == 3,
        ),
      ],
    );
  }

  BottomNavigationBarItem _buildItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
  }) {
    return BottomNavigationBarItem(
      label: "",
      icon: _navIcon(icon, isActive, label),
      activeIcon: _navIcon(activeIcon, true, label),
    );
  }

  Widget _navIcon(IconData icon, bool isActive, String label) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: isActive
          ? BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
            )
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min, // IMPORTANT
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.white : AppColors.textSecondary,
            size: 20, // keep consistent size
          ),

          if (isActive) ...[
            const HSpaceXs(),

            // THIS FIXES OVERFLOW
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: AppTypography.bodyXs.copyWith(color: AppColors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  int _getCurrentIndex() {
    if (currentRoute.startsWith(AppRoutes.home)) return 0;
    if (currentRoute.startsWith(AppRoutes.service)) return 1;
    if (currentRoute.startsWith(AppRoutes.transactions)) return 2;
    if (currentRoute.startsWith(AppRoutes.profile)) return 3;
    return 0; // Home default
  }

  void _navigate(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.service);
        break;
      case 2:
        context.go(AppRoutes.transactions);
        break;
      case 3:
        context.go(AppRoutes.profile);
        break;
    }
  }
}
