import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class AppDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String? profileImageUrl;

  const AppDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)
                      : null,
                  child: profileImageUrl == null
                      ? const Icon(Icons.person, size: 30)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  userName,
                  style: AppTextStyles.h4.copyWith(color: AppColors.white),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    context.pop();
                    context.push('/profile');
                  },
                  child: Text(
                    'View Profile',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _DrawerItem(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  onTap: () {
                    context.pop();
                    context.push('/dashboard');
                  },
                ),
                _DrawerItem(
                  icon: Icons.school_outlined,
                  label: 'Students',
                  onTap: () {
                    context.pop();
                    context.push('/students');
                  },
                ),
                _DrawerItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'Fees',
                  onTap: () {
                    context.pop();
                    context.push('/fees');
                  },
                ),
                _DrawerItem(
                  icon: Icons.wallet_outlined,
                  label: 'Wallet',
                  onTap: () {
                    context.pop();
                    context.push('/wallet');
                  },
                ),
                _DrawerItem(
                  icon: Icons.notifications_none,
                  label: 'Notifications',
                  onTap: () {
                    context.pop();
                    context.push('/notifications');
                  },
                ),
                _DrawerItem(
                  icon: Icons.person_outline,
                  label: 'View Profile',
                  onTap: () {
                    context.pop();
                    context.push('/profile');
                  },
                ),
                _DrawerItem(
                  icon: Icons.school_outlined,
                  label: 'Edit Schools',
                  onTap: () {
                    context.pop();
                    context.push('/edit-schools');
                  },
                ),
                _DrawerItem(
                  icon: Icons.help_outline,
                  label: 'Help And Support',
                  onTap: () {
                    context.pop();
                    context.push('/support');
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _DrawerItem(
              icon: Icons.logout_outlined,
              label: 'Log Out',
              onTap: () {
                context.pop();
                _showLogoutDialog(context);
              },
              isLogout: true,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'No, Cancel',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              context.pop();
              context.go('/login');
            },
            child: const Text('Yes, Log Out'),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLogout;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? AppColors.error : AppColors.textPrimary,
      ),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isLogout ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
    );
  }
}
