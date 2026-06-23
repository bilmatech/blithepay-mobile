import 'package:flutter/material.dart';
import 'package:blithepay/core/navigation/index.dart';
import 'package:blithepay/shared/widgets/app_bar.dart';
import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/shared/widgets/layouts/spacing.dart';
import 'package:blithepay/core/storage/auth_local_storage.dart';
import 'package:blithepay/shared/widgets/layouts/app_text.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:blithepay/features/auth/data/models/auth_response_model.dart';
import 'package:blithepay/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:blithepay/features/profile/presentation/bloc/profile_event.dart';
import 'package:blithepay/features/profile/presentation/bloc/profile_state.dart';
import 'package:blithepay/shared/widgets/buttons/secondary_outlined_button.dart';
import 'package:blithepay/shared/widgets/dialogs/confirmation_bottom_sheet.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppAppBar(title: 'Account', showBackButton: false),
      //appBar: AppBar(title: const HeadingLg('Profile'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: StreamBuilder<UserModel?>(
            stream: context.read<AppLocalDataSource>().userStream,
            builder: (context, snapshot) {
              final user = snapshot.data;
              final firstName = user?.firstName ?? '';
              final lastName = user?.lastName ?? '';

              return Column(
                children: [
                  const VSpaceBase(),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.border, width: 2),
                    ),
                    child: const Icon(Icons.person, size: 40, color: AppColors.textTertiary),
                  ),
                  const VSpaceBase(),
                  HeadingXl('$firstName $lastName'),
                  // const SizedBox(height: 4),
                  // GestureDetector(
                  //   onTap: () {
                  //     context.push(AppRoutes.profileDetail);
                  //   },
                  //   child: BodySm('${user?.email}'),
                  // ),
                  const SizedBox(height: 16),
                  const Divider(height: 0.8, thickness: 0.1),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: [
                        _ProfileItem(
                          icon: Icons.person_outline,
                          label: 'Profile',
                          onTap: () => context.push(AppRoutes.profileDetail),
                        ),
                        // _ProfileItem(
                        //   icon: Icons.lock_outline,
                        //   label: 'Recurring payments',
                        //   onTap: () =>
                        //       context.push(AppRoutes.reocurringPayment),

                        //   //  onTap: () => context.push('/linked-students'),
                        // ),
                        _ProfileItem(
                          icon: Icons.lock_outline,
                          label: 'Change Transaction PIN',
                          onTap: () => context.push(AppRoutes.changePin),
                        ),
                        // _ProfileItem(
                        //   icon: Icons.school_outlined,
                        //   label: 'Children',
                        //   onTap: () => context.push('/linked-students'),
                        // ),
                        // _ProfileItem(
                        //   icon: Icons.payment_outlined,
                        //   label: 'Pay Fees',
                        //   onTap: () => context.push('/pay-fees'),
                        // ),
                        // _ProfileItem(
                        //   icon: Icons.account_balance_wallet_outlined,
                        //   label: 'Wallet',
                        //   onTap: () => context.push(AppRoutes.fundWallet),
                        // ),

                        // _ProfileItem(
                        //   icon: Icons.person,
                        //   label: 'Account',
                        //   onTap: () => context.push(AppRoutes.profileDetail),
                        // ),
                        _ProfileItem(
                          icon: Icons.lock,
                          label: 'Change password',
                          onTap: () => context.push(
                            AppRoutes.forgotPassword,
                            extra: {'email': user?.email, 'fromProfile': true},
                          ),
                        ),
                        // _ProfileItem(
                        //   icon: Icons.notifications_none_outlined,
                        //   label: 'Notifications',
                        //   onTap: () => context.push('/notifications'),
                        // ),
                        _ProfileItem(
                          icon: Icons.help_outline,
                          label: 'Help & Support',
                          onTap: () => context.push('/help-support'),
                        ),
                        // _ProfileItem(
                        //   icon: Icons.logout_outlined,
                        //   label: 'Log Out',
                        //   isLogout: true,
                        //   onTap: () => _showLogoutDialog(context),
                        // ),
                        _ProfileItem(
                          icon: Icons.delete_outline,
                          label: 'Delete Account',
                          isLogout: true,
                          onTap: () => _showDeleteDialog(context),
                        ),
                        VSpaceBase(),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 100,
                            height: 40,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => _showLogoutDialog(context),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: AppColors.error.withValues(alpha: 0.8),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.logout_outlined, color: Colors.white, size: 18),
                                    HSpaceSm(),
                                    BodySm('Sign out', color: Colors.white),
                                  ],
                                ),
                              ),
                            ),
                          ),
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
    ConfirmationBottomSheet.show(
      context,
      title: 'Logout',
      subtitle: 'Are you sure you want to logout?',
      confirmButtonLabel: 'Yes, Logout',
      cancelButtonLabel: 'No, Cancel',
      onConfirm: () async {
        final localDataSource = context.read<AppLocalDataSource>();
        await localDataSource.clearSession();
        context.go('/login');
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 24,
        ),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Delete account', style: AppTextStyles.h3, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text(
              'Are you sure want to delete account?',
              style: AppTextStyles.bodyRegular.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            BlocConsumer<ProfileBloc, ProfileState>(
              listener: (context, state) {
                if (state is ProfileDeleted) {
                  Navigator.of(context).pop();
                  context.go('/login');
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Account deleted successfully')));
                }

                if (state is ProfileError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              builder: (context, state) {
                return Row(
                  children: [
                    Expanded(
                      child: SecondaryOutlinedButton(
                        height: 40,
                        label: 'No, Cancel',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        height: 40,
                        label: 'Yes, Delete',
                        isLoading: state is ProfileLoading,
                        onPressed: () {
                          context.read<ProfileBloc>().add(const DeleteAccount());
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
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
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: isLogout ? AppColors.error : AppColors.textHint),
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
