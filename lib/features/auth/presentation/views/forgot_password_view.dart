import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/shared/widgets/background/auth_flow_background.dart';
import 'package:blithepay/shared/widgets/buttons/arrow_button_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/buttons/secondary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ForgotPasswordView extends StatefulWidget {
  final String? email;
  final bool fromProfile;

  const ForgotPasswordView({super.key, this.email, this.fromProfile = false});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleForgotPassword() {
    if (_formKey.currentState!.validate()) {
      // if (kDebugMode) {
      //   context.push(
      //     AppRoutes.verifyOtp,
      //     extra: {
      //       'email': _emailController.text,
      //       'flow': OtpFlow.forgotPassword,
      //       'fromProfile': widget.fromProfile,
      //     },
      //   );
      //   return;
      // }

      context.read<AuthBloc>().add(
        ForgotPasswordRequested(email: _emailController.text),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.otpSent) {
          context.push(
            AppRoutes.verifyOtp,
            extra: {
              'email': _emailController.text,
              'flow': OtpFlow.forgotPassword,
              'fromProfile': widget.fromProfile,
            },
          );
        }
      },
      child: AppScaffold(
        showBackButton: false,
        //   background: const AuthFlowBackground(),
        body: AuthBackgroundWrapper(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const BackArrowButtonIcon(),
                        const SizedBox(height: 12),
                         Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: 68,
                              height: 68,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/images/secure.png',
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          widget.fromProfile
                              ? 'Change Password'
                              : AppStrings.forgotPassword,
                          style: AppTextStyles.h2,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          AppStrings.forgotPasswordSubtitle,
                          style: AppTextStyles.bodyRegular,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        AppTextField(
                          label: AppStrings.email,
                          hint: AppStrings.enterEmail,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                          readOnly: widget.fromProfile,
                        ),
                        const SizedBox(height: 40),

                        if (!widget.fromProfile) ...[
                          const SizedBox(height: 16),
                          Center(
                            child: SecondaryButton(
                              label: 'Back To Log In',
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                        PrimaryButton(
                          label: AppStrings.changePassword,
                          onPressed: _handleForgotPassword,
                          isLoading: state.status == AuthStatus.loading,
                          isEnabled: state.status != AuthStatus.loading,
                        ),
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
