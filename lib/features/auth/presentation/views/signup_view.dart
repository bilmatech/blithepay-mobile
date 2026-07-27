import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:country_picker/country_picker.dart';
import 'package:blithepay/core/utils/validators.dart';
import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_strings.dart';
import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/shared/widgets/inputs/app_text_field.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:blithepay/shared/widgets/step_progress_indicator.dart';
import 'package:blithepay/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blithepay/features/auth/presentation/bloc/auth_event.dart';
import 'package:blithepay/features/auth/presentation/bloc/auth_state.dart';
import 'package:blithepay/shared/widgets/background/auth_flow_background.dart';
import 'package:blithepay/shared/widgets/web_page_view.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_event.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  final _formKey = GlobalKey<FormState>();
  bool _agreedToTerms = false;

  Country _selectedCountry = Country(
    phoneCode: '234',
    countryCode: 'NG',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'Nigeria',
    example: '08012345678',
    displayName: 'Nigeria (NG)',
    displayNameNoCountryCode: 'Nigeria',
    e164Key: '234-NG',
  );

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    if (_formKey.currentState!.validate()) {
      if (!_agreedToTerms) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please accept the Terms and Conditions')));
        return;
      }

      context.read<AuthBloc>().add(
        SignupRequested(
          email: _emailController.text,
          password: _passwordController.text,
          fullName: _nameController.text,
          phoneNumber: _phoneController.text,
        ),
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
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.signupSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ??
                    'Registration successful! Verification email sent.',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        if (state.status == AuthStatus.otpSent) {
          context.push(AppRoutes.verifyOtp, extra: {'flow': OtpFlow.signup});
        }

        if (state.status == AuthStatus.authenticated) {
          _navigateAfterAuth();
        }
      },
      child: AppScaffold(
        showBackButton: false,
        // background: const AuthFlowBackground(),
        body: AuthBackgroundWrapper(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      const StepProgressIndicator(
                        currentStep: 1,
                        totalSteps: 3,
                        label: AppStrings.personalInfo,
                      ),
                      const SizedBox(height: 24),
                      const Text(AppStrings.createAccountTitle, style: AppTextStyles.h2),
                      const SizedBox(height: 24),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextField(
                              label: AppStrings.fullName,

                              controller: _nameController,
                              validator: Validators.validateFullName,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              label: AppStrings.email,
                              hint: AppStrings.enterEmail,
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.validateEmail,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              label: AppStrings.phoneNumber,
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              validator: Validators.validatePhoneNumber,
                              prefix: GestureDetector(
                                onTap: () {
                                  showCountryPicker(
                                    context: context,
                                    showPhoneCode: true,
                                    onSelect: (Country country) {
                                      setState(() => _selectedCountry = country);
                                    },
                                  );
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(width: 12),
                                    Text(
                                      _selectedCountry.flagEmoji,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '+${_selectedCountry.phoneCode}',
                                      style: AppTextStyles.bodyRegular,
                                    ),
                                    const SizedBox(width: 8),
                                    Container(height: 24, width: 1, color: AppColors.textTertiary),
                                    const SizedBox(width: 8),
                                  ],
                                ),
                              ),
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
                            const SizedBox(height: 16),
                            AppTextField(
                              label: AppStrings.confirmPassword,
                              hint: AppStrings.enterPassword,
                              controller: _confirmPasswordController,
                              obscureText: true,
                              showPasswordToggle: true,
                              validator: (value) =>
                                  Validators.validatePasswordMatch(_passwordController.text, value),
                            ),
                            const SizedBox(height: 18),

                            // Row(
                            //   children: [
                            //     const Expanded(
                            //       child: Divider(color: AppColors.border),
                            //     ),
                            //     const SizedBox(width: 12),
                            //     Text(
                            //       AppStrings.orContinueWith,
                            //       style: AppTextStyles.bodySmall.copyWith(
                            //         color: AppColors.textSecondary,
                            //         fontWeight: FontWeight.w600,
                            //       ),
                            //     ),
                            //     const SizedBox(width: 12),
                            //     const Expanded(
                            //       child: Divider(color: AppColors.border),
                            //     ),
                            //   ],
                            // ),
                            // const SizedBox(height: 18),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.center,
                            //   children: [
                            //     // Social Login Section
                            //     SocialAuthButton(
                            //       iconPath: 'assets/images/google.svg',
                            //       onPressed: () => context.read<AuthBloc>().add(
                            //         const GoogleSignInRequested(),
                            //       ),
                            //       isLoading: state.status == AuthStatus.loading,
                            //     ),
                            //     const SizedBox(width: 12),
                            //     SocialAuthButton(
                            //       iconPath: 'assets/images/apple.svg',
                            //       onPressed: () => context.read<AuthBloc>().add(
                            //         const AppleSignInRequested(),
                            //       ),
                            //       isLoading: state.status == AuthStatus.loading,
                            //     ),
                            //   ],
                            // ),
                            const SizedBox(height: 24),

                            Row(
                              children: [
                                Checkbox(
                                  value: _agreedToTerms,
                                  onChanged: (value) =>
                                      setState(() => _agreedToTerms = value ?? false),
                                ),
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'By registering your account, you accept the ',
                                      style: AppTextStyles.bodySmall,
                                      children: [
                                        TextSpan(
                                          text: AppStrings.termsAndConditions,
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) => const WebPageView(
                                                    url: 'https://www.blithepay.com/terms',
                                                    title: 'Terms & Conditions',
                                                  ),
                                                ),
                                              );
                                            },
                                        ),
                                        const TextSpan(
                                          text: ' and ',
                                          style: AppTextStyles.bodySmall,
                                        ),
                                        TextSpan(
                                          text: AppStrings.privacyPolicy,
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) => const WebPageView(
                                                    url: 'https://www.blithepay.com/privacy',
                                                    title: 'Privacy Policy',
                                                  ),
                                                ),
                                              );
                                            },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      PrimaryButton(
                        label: AppStrings.createAccount,
                        onPressed: _handleSignup,
                        isLoading: state.status == AuthStatus.loading,
                        isEnabled: state.status != AuthStatus.loading,
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: Text.rich(
                          TextSpan(
                            text: AppStrings.alreadyhaveAnAccount,
                            style: AppTextStyles.bodyRegular,
                            children: [
                              TextSpan(
                                text: AppStrings.signIn,
                                style: AppTextStyles.link,
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    context.go(AppRoutes.login);
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
