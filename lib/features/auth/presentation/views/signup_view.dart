import 'package:blithepay/core/constants/app_colors.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please accept the Terms and Conditions'),
          ),
        );
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.signupSuccess) {
          context.push(
            AppRoutes.verifyOtp,
            extra: {'email': _emailController.text, 'flow': OtpFlow.signup},
          );
        } else if (state.status == AuthStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Signup failed')),
          );
        }
      },
      child: AppScaffold(
        showBackButton: false,
        centerTitle: true,
        title: AppStrings.createAccount,
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
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
                              Container(
                                height: 24,
                                width: 1,
                                color: AppColors.textTertiary,
                              ),
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
                        validator: (value) => Validators.validatePasswordMatch(
                          _passwordController.text,
                          value,
                        ),
                      ),
                      const SizedBox(height: 16),
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
                                text:
                                    'By registering your school, you accept the ',
                                style: AppTextStyles.bodySmall,
                                children: [
                                  TextSpan(
                                    text: 'Terms and Conditions',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.primary,
                                      // decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        // Navigate or open link
                                        // Example:
                                        // Navigator.push(context, MaterialPageRoute(...));
                                        // or launchUrl(...)
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      PrimaryButton(
                        label: AppStrings.createAccount,
                        onPressed: _handleSignup,
                        isLoading: state.status == AuthStatus.loading,
                        isEnabled: state.status != AuthStatus.loading,
                      ),
                      const SizedBox(height: 16),

                      Center(
                        child: Text.rich(
                          TextSpan(
                            text: AppStrings.alreadyhaveAnAccount,
                            style: AppTextStyles.bodySmall,
                            children: [
                              TextSpan(
                                text: AppStrings.signIn,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
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
              ),
            );
          },
        ),
      ),
    );
  }
}
