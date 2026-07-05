import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:blithepay/core/services/biometric_crypto_service.dart';
import 'package:blithepay/features/auth/data/repositories/auth_repository.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppAppBar(title: 'Account', showBackButton: false),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: StreamBuilder<UserModel?>(
            stream: context.read<AppLocalDataSource>().userStream,
            builder: (context, snapshot) {
              final user = snapshot.data;
              final firstName = user?.firstName ?? '';
              final lastName = user?.lastName ?? '';

              final profilePicture = user?.profileImage ?? '';

              return Column(
                children: [
                  const VSpaceBase(),
                  // Avatar with soft glowing background
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.05),
                    ),
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          width: 2.5,
                        ),
                      ),
                      child: profilePicture.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                profilePicture,
                                fit: BoxFit.cover,
                                key: ValueKey(profilePicture),
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.person_rounded,
                                      size: 44,
                                      color: AppColors.primary,
                                    ),
                              ),
                            )
                          : const Icon(
                              Icons.person_rounded,
                              size: 44,
                              color: AppColors.primary,
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  HeadingXl(
                    '$firstName $lastName',
                  ),
                  const SizedBox(height: 4),
                  BodySm(
                    user?.email ?? 'Account Settings',
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: ListView(
                      children: [
                        // Settings Group Card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE8ECF5)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF061657).withValues(alpha: 0.02),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              _ModernProfileItem(
                                icon: Icons.person_outline_rounded,
                                iconBgColor: AppColors.primary.withValues(alpha: 0.08),
                                iconColor: AppColors.primary,
                                label: 'Profile Details',
                                onTap: () {
                                  context.push(AppRoutes.profileDetail).then((_) {
                                    if (context.mounted) {
                                      context.read<ProfileBloc>().add(
                                        const GetProfileEvent(),
                                      );
                                      context.read<AppLocalDataSource>().getSession();
                                    }
                                  });
                                },
                              ),
                              const _Divider(),
                              _BiometricToggleItem(userEmail: user?.email ?? ''),
                              const _Divider(),
                              _ModernProfileItem(
                                icon: Icons.pin_outlined,
                                iconBgColor: const Color(0xFFF0F3FF),
                                iconColor: AppColors.primary,
                                label: 'Change Transaction PIN',
                                onTap: () => context.push(AppRoutes.changePin),
                              ),
                              const _Divider(),
                              _ModernProfileItem(
                                icon: Icons.lock_open_rounded,
                                iconBgColor: const Color(0xFFF0F3FF),
                                iconColor: AppColors.primary,
                                label: 'Change Password',
                                onTap: () => context.push(
                                  AppRoutes.forgotPassword,
                                  extra: {'email': user?.email, 'fromProfile': true},
                                ),
                              ),
                              const _Divider(),
                              _ModernProfileItem(
                                icon: Icons.help_outline_rounded,
                                iconBgColor: const Color(0xFFF0F3FF),
                                iconColor: AppColors.primary,
                                label: 'Help & Support',
                                onTap: () => context.push('/help-support'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Destructive Group Card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFEECEE)),
                          ),
                          child: Column(
                            children: [
                              _ModernProfileItem(
                                icon: Icons.delete_outline_rounded,
                                iconBgColor: const Color(0xFFFFF2F3),
                                iconColor: AppColors.error,
                                label: 'Delete Account',
                                isDestructive: true,
                                onTap: () => _showDeleteDialog(context),
                              ),
                              const _DestructiveDivider(),
                              _ModernProfileItem(
                                icon: Icons.logout_rounded,
                                iconBgColor: const Color(0xFFFFF2F3),
                                iconColor: AppColors.error,
                                label: 'Sign Out',
                                isDestructive: true,
                                onTap: () => _showLogoutDialog(context),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
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
            const Text(
              'Delete account',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Are you sure want to delete account?',
              style: AppTextStyles.bodyRegular.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            BlocConsumer<ProfileBloc, ProfileState>(
              listener: (context, state) {
                if (state is ProfileDeleted) {
                  Navigator.of(context).pop();
                  context.go('/login');
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
                          context.read<ProfileBloc>().add(
                            const DeleteAccount(),
                          );
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

class _ModernProfileItem extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ModernProfileItem({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: isDestructive ? AppColors.error : const Color(0xFF061657),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDestructive
                  ? AppColors.error.withValues(alpha: 0.4)
                  : const Color(0xFF9EA6C6),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 60, right: 16),
      child: Divider(
        height: 1,
        thickness: 1,
        color: const Color(0xFFE8ECF5).withValues(alpha: 0.6),
      ),
    );
  }
}

class _DestructiveDivider extends StatelessWidget {
  const _DestructiveDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 60, right: 16),
      child: Divider(
        height: 1,
        thickness: 1,
        color: const Color(0xFFFEECEE).withValues(alpha: 0.6),
      ),
    );
  }
}

class _BiometricToggleItem extends StatefulWidget {
  final String userEmail;

  const _BiometricToggleItem({required this.userEmail});

  @override
  State<_BiometricToggleItem> createState() => _BiometricToggleItemState();
}

class _BiometricToggleItemState extends State<_BiometricToggleItem> {
  bool _isEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricStatus();
  }

  Future<void> _loadBiometricStatus() async {
    final localDataSource = context.read<AppLocalDataSource>();
    final enabled = await localDataSource.isBiometricsEnabled();
    setState(() {
      _isEnabled = enabled;
    });
  }

  Future<void> _toggleBiometrics(bool value) async {
    if (_isLoading) return;
    if (widget.userEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot enable biometric login without a logged-in user email.")),
      );
      return;
    }

    final localDataSource = context.read<AppLocalDataSource>();
    final authRepository = context.read<AuthRepository>();

    if (value) {
      setState(() {
        _isLoading = true;
      });

      try {
        // 1. Generate key pair natively in secure hardware
        final publicKey = await BiometricCryptoService.generateKeyPair();
        if (publicKey == null || publicKey.isEmpty) {
          throw Exception("Biometric key pair generation cancelled or failed.");
        }

        // 2. Get/create device ID
        final deviceId = await localDataSource.getOrCreateDeviceId();

        // 3. Enroll device on backend NestJS API
        await authRepository.enrollBiometric(
          email: widget.userEmail,
          deviceId: deviceId,
          publicKey: publicKey,
        );

        // 4. Save settings locally
        await localDataSource.setBiometricsEnabled(true);
        await localDataSource.setBiometricEmail(widget.userEmail);

        setState(() {
          _isEnabled = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Biometric Login enabled successfully!")),
          );
        }
      } catch (e) {
        String errorMsg = "Enrollment failed.";
        if (e is PlatformException) {
          errorMsg = e.message ?? errorMsg;
        } else {
          errorMsg = "Enrollment failed: ${e.toString().replaceAll('Exception: ', '')}";
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg)),
          );
        }
        setState(() {
          _isEnabled = false;
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      setState(() {
        _isLoading = true;
      });
      try {
        await localDataSource.setBiometricsEnabled(false);
        setState(() {
          _isEnabled = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Biometric Login disabled.")),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${e.toString()}")),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fingerprint_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Biometric Login',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Color(0xFF061657),
              ),
            ),
          ),
          if (_isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          else
            Switch.adaptive(
              value: _isEnabled,
              activeTrackColor: AppColors.primary,
              onChanged: _toggleBiometrics,
            ),
        ],
      ),
    );
  }
}
