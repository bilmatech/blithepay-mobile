import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        if (state.status == AuthStatus.authenticated) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        } else if (state.status == AuthStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Signup failed')),
          );
        }
      },
      child: AppScaffold(
        title: AppStrings.createAccount,
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return SingleChildScrollView(
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
                        const Expanded(
                          child: Text(
                            'By registering your school, you accept the Terms and Conditions',
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      text: AppStrings.createAccount,
                      onPressed: _handleSignup,
                      isLoading: state.status == AuthStatus.loading,
                      isEnabled: state.status != AuthStatus.loading,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
