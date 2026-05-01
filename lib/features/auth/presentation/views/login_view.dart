import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/shared/widgets/background/auth_flow_background.dart';
import 'package:blithepay/shared/widgets/buttons/secondary_outlined_button.dart';
import 'package:blithepay/shared/widgets/buttons/social_auth_button.dart';
import 'package:flutter/foundation.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/buttons/secondary_button.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_event.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    if (kDebugMode) {
      _emailController.text = 'toyabdul345@gmail.com';
      _passwordController.text = '1Password@';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      // if (kDebugMode) {
      //   context.go(AppRoutes.linkedStudents);
      //   context.read<DashboardBloc>().add(const FetchDashboardData());
      //   return;
      // }

      context.read<AuthBloc>().add(
        LoginRequested(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.go(AppRoutes.home);

          context.read<DashboardBloc>().add(const FetchDashboardData());
        } else if (state.status == AuthStatus.error &&
            state.errorMessage?.contains('not verified') == true) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? ''),
                behavior: SnackBarBehavior.floating,
              ),
            );

          context.go(
            AppRoutes.verifyOtp,
            extra: {
              'email': _emailController.text,
              'flow': OtpFlow.verifyEmail,
            },
          );
        } else if (state.status == AuthStatus.error) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage ?? 'An unknown error occurred',
                ),
              ),
            );
        }
      },
      child: AppScaffold(
        showBackButton: false,
        //background: const AuthFlowBackground(),
        body: AuthBackgroundWrapper(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        const Text(
                          AppStrings.welcomeBack,
                          style: AppTextStyles.h2,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          AppStrings.welcomeBackSubtitle,
                          style: AppTextStyles.bodyRegular,
                        ),
                        const SizedBox(height: 32),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextField(
                              label: AppStrings.email,
                              hint: AppStrings.enterEmail,
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.validateEmail,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              label: AppStrings.password,
                              hint: AppStrings.enterPassword,
                              controller: _passwordController,
                              obscureText: true,
                              showPasswordToggle: true,
                              validator: Validators.validatePassword,
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: SecondaryButton(
                                label: AppStrings.forgotPassword,
                                textColor: AppColors.borderDark,
                                onPressed: () =>
                                    context.push(AppRoutes.forgotPassword),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          label: AppStrings.logIn,
                          onPressed: _handleLogin,
                          isLoading: state.status == AuthStatus.loading,
                          isEnabled: state.status != AuthStatus.loading,
                        ),
                        const SizedBox(height: 40),

                        SizedBox(
                          width: double.infinity,
                          child: SecondaryOutlinedButton(
                            label: AppStrings.biometricSignIn,
                            textStyle: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: AppColors.borderDark,
                            ),
                            onPressed: () => context.push(AppRoutes.biometric),
                            // borderColor: AppColors.primary,
                            leading: const Icon(
                              Icons.fingerprint,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        Center(
                          child: GestureDetector(
                            onTap: () => context.push(AppRoutes.signup),
                            child: RichText(
                              text: const TextSpan(
                                text: "Don't have an account? ",
                                style: AppTextStyles.bodyRegular,
                                children: [
                                  TextSpan(
                                    text: 'Sign Up',
                                    style: AppTextStyles.link,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(color: AppColors.border),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              AppStrings.orContinueWith,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Divider(color: AppColors.border),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Social Login Section
                            SocialAuthButton(
                              iconPath: 'assets/images/google.svg',
                              onPressed: () => context.read<AuthBloc>().add(
                                const GoogleSignInRequested(),
                              ),
                              isLoading: state.status == AuthStatus.loading,
                            ),
                            const SizedBox(width: 12),
                            SocialAuthButton(
                              iconPath: 'assets/images/apple.svg',
                              onPressed: () => context.read<AuthBloc>().add(
                                const AppleSignInRequested(),
                              ),
                              isLoading: state.status == AuthStatus.loading,
                            ),
                          ],
                        ),
                        const SizedBox(height: 42),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
