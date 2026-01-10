import 'package:blithepay_mobile/core/constants/app_colors.dart';
import 'package:blithepay_mobile/core/navigation/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavigationWidget extends StatelessWidget {
  final String currentRoute;

  const BottomNavigationWidget({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      currentIndex: _getCurrentIndex(),
      onTap: (index) => _navigate(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school_outlined),
          activeIcon: Icon(Icons.school),
          label: 'Students',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long),
          label: 'Fees',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_outlined),
          activeIcon: Icon(Icons.account_balance_wallet),
          label: 'Wallet',
        ),
      ],
    );
  }

  int _getCurrentIndex() {
    if (currentRoute.contains('dashboard')) return 0;
    if (currentRoute.contains('students') ||
        currentRoute.contains('linked-students')) {
      return 1;
    }
    if (currentRoute.contains('fees') || currentRoute.contains('pay-fees')) {
      return 2;
    }
    if (currentRoute.contains('wallet') ||
        currentRoute.contains('transactions')) {
      return 3;
    }
    return 0;
  }

  void _navigate(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.dashboard);
        break;
      case 1:
        context.push(AppRoutes.linkedStudents);
        break;
      case 2:
        context.push(AppRoutes.payFees);
        break;
      case 3:
        context.push(AppRoutes.walletManagement);
        break;
    }
  }
}
