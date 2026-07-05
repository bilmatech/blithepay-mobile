import 'package:blithepay/core/navigation/index.dart';
import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_strings.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:blithepay/shared/widgets/buttons/secondary_outlined_button.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:blithepay/core/storage/auth_local_storage.dart';
import 'package:blithepay/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blithepay/features/auth/presentation/bloc/auth_event.dart';
import 'package:blithepay/features/auth/presentation/bloc/auth_state.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_event.dart';

class BiometricAuthView extends StatefulWidget {
  const BiometricAuthView({super.key});

  @override
  State<BiometricAuthView> createState() => _BiometricAuthViewState();
}

class _BiometricAuthViewState extends State<BiometricAuthView> {
  @override
  void initState() {
    super.initState();
    // Automatically trigger biometric flow once the view frames are laid out
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startBiometricLogin();
    });
  }

  /// Fetches local biometric credentials (email, device id),
  /// and dispatches the login signature request to the AuthBloc.
  Future<void> _startBiometricLogin() async {
    if (!mounted) return;
    final localDataSource = context.read<AppLocalDataSource>();
    final email = await localDataSource.getBiometricEmail();
    final deviceId = await localDataSource.getOrCreateDeviceId();

    if (email == null || email.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No enrolled biometric email found. Please login with password.")),
        );
        context.go(AppRoutes.login);
      }
      return;
    }

    if (mounted) {
      context.read<AuthBloc>().add(
        BiometricLoginRequested(email: email, deviceId: deviceId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.go(AppRoutes.home);
          context.read<DashboardBloc>().add(const FetchDashboardData());
        } else if (state.status == AuthStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? "Biometric authentication failed"),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == AuthStatus.loading &&
            state.loadingType == LoadingType.biometric;

        return AppScaffold(
          showBackButton: false,
          body: SafeArea(
            child: Container(
              color: AppColors.white,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  const Text(AppStrings.welcomeBack, style: AppTextStyles.h2),
                  const SizedBox(height: 8),
                  const Text(
                    AppStrings.welcomeBackSubtitle,
                    style: AppTextStyles.bodyRegular,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: isLoading ? null : _startBiometricLogin,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: .12),
                              width: 4,
                            ),
                          ),
                        ),
                        Container(
                          width: 190,
                          height: 190,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.18),
                              width: 2,
                            ),
                          ),
                        ),
                        Container(
                          width: 150,
                          height: 150,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surface,
                          ),
                          child: Center(
                            child: isLoading
                                ? const SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary,
                                    ),
                                  )
                                : const Icon(
                                    Icons.fingerprint,
                                    color: AppColors.primary,
                                    size: 60,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isLoading ? 'VERIFYING...' : 'TOUCH SENSOR TO LOGIN',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isLoading ? AppColors.textSecondary : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    label: "Retry Biometrics",
                    isLoading: isLoading,
                    onPressed: () => _startBiometricLogin(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryOutlinedButton(
                          label: AppStrings.usePasswordInstead,
                          onPressed: () => context.go(AppRoutes.login),
                          borderColor: AppColors.border,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
