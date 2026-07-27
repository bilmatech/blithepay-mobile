import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'package:blithepay/core/constants/app_colors.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import 'package:blithepay/core/storage/auth_local_storage.dart';
import '../../../../shared/widgets/buttons/secondary_button.dart';
import 'package:blithepay/shared/widgets/buttons/social_auth_button.dart';
import 'package:blithepay/shared/widgets/background/auth_flow_background.dart';
import 'package:blithepay/features/auth/data/repositories/auth_repository.dart';
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
  bool _biometricsEnabled = false;
  String? _biometricEmail;
  String? _savedEmail;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    if (kDebugMode) {
      _emailController.text = '';
      _passwordController.text = '';
    }

    _loadSavedEmail();
    _checkBiometrics();
  }

  Future<void> _loadSavedEmail() async {
    final authRepository = context.read<AuthRepository>();
    final savedEmail = await authRepository.getSavedEmail();
    if (savedEmail != null && mounted) {
      setState(() {
        _savedEmail = savedEmail;
        _emailController.text = savedEmail;
      });
    }
  }

  Future<void> _checkBiometrics() async {
    final localDataSource = context.read<AppLocalDataSource>();
    final enabled = await localDataSource.isBiometricsEnabled();
    final email = await localDataSource.getBiometricEmail();
    if (mounted) {
      setState(() {
        _biometricsEnabled = enabled && email != null && email.isNotEmpty;
        _biometricEmail = email;
      });
    }
  }

  Future<void> _handleBiometricLogin() async {
    if (_biometricEmail == null || _biometricEmail!.isEmpty) return;
    final localDataSource = context.read<AppLocalDataSource>();
    final deviceId = await localDataSource.getOrCreateDeviceId();
    if (mounted) {
      context.read<AuthBloc>().add(
        BiometricLoginRequested(email: _biometricEmail!, deviceId: deviceId),
      );
    }
  }

  Future<void> _navigateAfterAuth() async {
    final localDataSource = context.read<AppLocalDataSource>();
    final isEnabled = await localDataSource.isBiometricsEnabled();
    final dontShow = await localDataSource.getDontShowBiometricPrompt();

    if (!mounted) return;
    if (!isEnabled && !dontShow) {
      context.go(AppRoutes.enableBiometrics, extra: _emailController.text);
    } else {
      context.go(AppRoutes.home);
      context.read<DashboardBloc>().add(const FetchDashboardData());
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
        LoginRequested(email: _emailController.text, password: _passwordController.text),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          _navigateAfterAuth();
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
            extra: {'email': _emailController.text, 'flow': OtpFlow.verifyEmail},
          );
        } else if (state.status == AuthStatus.error) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'An unknown error occurred')),
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
                        const Text(AppStrings.welcomeBack, style: AppTextStyles.h2),
                        const SizedBox(height: 8),
                        const Text(
                          AppStrings.welcomeBackSubtitle,
                          style: AppTextStyles.bodyRegular,
                        ),
                        const SizedBox(height: 32),
                        if (_savedEmail != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                  child: const Icon(
                                    Icons.person_outline,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Logged in as',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textTertiary,
                                        ),
                                      ),
                                      Text(
                                        _savedEmail!,
                                        style: AppTextStyles.bodyRegular.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final authRepository = context.read<AuthRepository>();
                                    await authRepository.clearSavedEmail();
                                    setState(() {
                                      _savedEmail = null;
                                      _emailController.clear();
                                    });
                                  },
                                  child: Text(
                                    'Switch',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_savedEmail == null) ...[
                              AppTextField(
                                label: AppStrings.email,
                                hint: AppStrings.enterEmail,
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: Validators.validateEmail,
                              ),
                              const SizedBox(height: 16),
                            ],
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
                                onPressed: () => context.push(AppRoutes.forgotPassword),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: PrimaryButton(
                                label: AppStrings.logIn,
                                onPressed: _handleLogin,
                                isLoading:
                                    state.status == AuthStatus.loading &&
                                    state.loadingType == LoadingType.email,
                                isEnabled: state.status != AuthStatus.loading,
                              ),
                            ),
                            if (_biometricsEnabled) ...[
                              const SizedBox(width: 12),
                              InkWell(
                                onTap: state.status == AuthStatus.loading
                                    ? null
                                    : _handleBiometricLogin,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.primary),
                                    borderRadius: BorderRadius.circular(12),
                                    color: AppColors.primary.withValues(alpha: 0.05),
                                  ),
                                  child:
                                      state.status == AuthStatus.loading &&
                                          state.loadingType == LoadingType.biometric
                                      ? const Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.primary,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.fingerprint,
                                          color: AppColors.primary,
                                          size: 28,
                                        ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 32),

                        Center(
                          child: GestureDetector(
                            onTap: () => context.push(AppRoutes.signup),
                            child: RichText(
                              text: const TextSpan(
                                text: "Don't have an account? ",
                                style: AppTextStyles.bodyRegular,
                                children: [TextSpan(text: 'Sign Up', style: AppTextStyles.link)],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          children: [
                            const Expanded(child: Divider(color: AppColors.border)),
                            const SizedBox(width: 12),
                            Text(
                              AppStrings.orContinueWith,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(child: Divider(color: AppColors.border)),
                          ],
                        ),
                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Social Login Section
                            SocialAuthButton(
                              iconPath: 'assets/images/google.svg',
                              onPressed: () =>
                                  context.read<AuthBloc>().add(const GoogleSignInRequested()),
                              isLoading: state.loadingType == LoadingType.google,
                            ),
                            const SizedBox(width: 12),
                            SocialAuthButton(
                              iconPath: 'assets/images/apple.svg',
                              onPressed: () =>
                                  context.read<AuthBloc>().add(const AppleSignInRequested()),
                              isLoading: state.loadingType == LoadingType.apple,
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
