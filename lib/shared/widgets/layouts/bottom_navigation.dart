import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/navigation/app_routes.dart';
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
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      currentIndex: currentIndex,
      onTap: (index) => _navigate(context, index),
      items: [
        _buildItem(
          icon: Icons.wallet_outlined,
          activeIcon: Icons.wallet_outlined,
          label: 'Wallet',
          isActive: currentIndex == 0,
        ),
        _buildItem(
          icon: Icons.school_outlined,
          activeIcon: Icons.school_outlined,
          label: 'Link Child',
          isActive: currentIndex == 1,
        ),

        _buildItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Profile',
          isActive: currentIndex == 2,
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
      label: label,
      icon: _navIcon(icon, isActive),
      activeIcon: _navIcon(activeIcon, true),
    );
  }

  Widget _navIcon(IconData icon, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: isActive
          ? const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            )
          : null,
      child: Icon(
        icon,
        color: isActive ? AppColors.white : AppColors.textSecondary,
      ),
    );
  }

  int _getCurrentIndex() {
    if (currentRoute.startsWith(AppRoutes.home)) return 0;
    if (currentRoute.startsWith(AppRoutes.linkedStudents)) return 1;
    if (currentRoute.startsWith(AppRoutes.profile)) return 2;
    return 1; // Link Child default
  }

  void _navigate(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.linkedStudents);
        break;
      case 2:
        context.go(AppRoutes.profile);
        break;
    }
  }
}
