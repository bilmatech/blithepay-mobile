import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/core/navigation/index.dart';
import 'package:blithepay/core/storage/auth_local_storage.dart';
import 'package:blithepay/features/auth/data/models/auth_response_model.dart';
import 'package:blithepay/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:blithepay/features/profile/presentation/bloc/profile_event.dart';
import 'package:blithepay/features/profile/presentation/bloc/profile_state.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final localDataSource = context.read<AppLocalDataSource>();

    return AppScaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FutureBuilder<AuthResponseModel?>(
            future: localDataSource.getSession(),
            builder: (context, snapshot) {
              final user = snapshot.data?.user;
              final firstName = user?.firstName ?? '';
              final lastName = user?.lastName ?? '';

              return Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 36,
                        child: Icon(Icons.person, size: 36),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$firstName $lastName',
                              style: AppTextStyles.h4,
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () {
                                context.push(AppRoutes.profileDetail);
                              },
                              child: Text(
                                '${user?.email}',
                                style: AppTextStyles.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, thickness: 1),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: [
                        _ProfileItem(
                          icon: Icons.school_outlined,
                          label: 'Children',
                          onTap: () => context.push('/linked-students'),
                        ),
                        // _ProfileItem(
                        //   icon: Icons.payment_outlined,
                        //   label: 'Pay Fees',
                        //   onTap: () => context.push('/pay-fees'),
                        // ),
                        _ProfileItem(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Wallet',
                          onTap: () => context.push(AppRoutes.fundWallet),
                        ),
                        // _ProfileItem(
                        //   icon: Icons.notifications_none_outlined,
                        //   label: 'Notifications',
                        //   onTap: () => context.push('/notifications'),
                        // ),
                        _ProfileItem(
                          icon: Icons.person,
                          label: 'Account',
                          onTap: () => context.push(AppRoutes.profileDetail),
                        ),
                        _ProfileItem(
                          icon: Icons.lock,
                          label: 'Change Password',
                          onTap: () => context.push(
                            AppRoutes.forgotPassword,
                            extra: {'email': user?.email, 'fromProfile': true},
                          ),
                        ),
                        _ProfileItem(
                          icon: Icons.help_outline,
                          label: 'Help & Support',
                          onTap: () => context.push('/help-support'),
                        ),

                        _ProfileItem(
                          icon: Icons.delete,
                          label: 'Delete My Account',
                          isLogout: true,
                          onTap: () => _showDeleteDialog(context),
                        ),
                        _ProfileItem(
                          icon: Icons.logout_outlined,
                          label: 'Log Out',
                          isLogout: true,
                          onTap: () => _showLogoutDialog(context),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            onPressed: () async {
              final localDataSource = context.read<AppLocalDataSource>();
              await localDataSource.clearSession();
              context.pop();
              context.go('/login');
            },
            child: const Text('Yes, Log Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Column(
          children: [
            const Icon(Icons.error_outline, color: AppColors.primary, size: 48),
            const SizedBox(height: 16),
            Text(
              'Are you sure you want to proceed?',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'If you continue, your account and all associated data will be permanently deleted.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),

            BlocConsumer<ProfileBloc, ProfileState>(
              listener: (context, state) {
                if (state is ProfileDeleted) {
                  Navigator.of(context).pop(); // close dialog

                  context.go('/login'); // navigate

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account deleted successfully'),
                    ),
                  );
                }

                if (state is ProfileError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              builder: (context, state) {
                return SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    isLoading: state is ProfileLoading,
                    label: 'Delete',
                    backgroundColor: AppColors.primary,
                    onPressed: () {
                      context.read<ProfileBloc>().add(const DeleteAccount());
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () {
                context.pop();
              },
              child: Text(
                'Cancel',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLogout;

  const _ProfileItem({
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
