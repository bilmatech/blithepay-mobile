import 'package:blithepay/core/constants/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/background/auth_flow_background.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ResetPasswordView extends StatefulWidget {
  final String email;
  final bool fromProfile;

  const ResetPasswordView({
    super.key,
    required this.email,
    this.fromProfile = false,
  });

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleResetPassword() async {
    final authState = context.read<AuthBloc>().state;
    final token = authState.token;
    if (_formKey.currentState!.validate()) {
      // if (kDebugMode) {
      //   context.go(AppRoutes.passwordChanged, extra: widget.fromProfile);
      //   return;
      // }
      context.read<AuthBloc>().add(
        ResetPasswordRequested(
          token: token ?? '',
          email: widget.email,
          newPassword: _newPasswordController.text,
          confirmPassword: _confirmPasswordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.passwordReset) {
          context.go(AppRoutes.passwordChanged, extra: widget.fromProfile);
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/key.png',
                              width: 60,
                              height: 60,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
          
                        Text(
                          widget.fromProfile
                              ? AppStrings.changePassword
                              : AppStrings.resetPassword,
                          style: AppTextStyles.h2,
                        ),
                        const Text(
                          AppStrings.enterNewPassword,
                          style: AppTextStyles.bodyRegular,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        AppTextField(
                          label: AppStrings.newPassword,
                          hint: AppStrings.enterPassword,
                          controller: _newPasswordController,
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
                            _newPasswordController.text,
                            value,
                          ),
                        ),
                        const SizedBox(height: 32),
                        PrimaryButton(
                          label: AppStrings.changePassword,
                          onPressed: _handleResetPassword,
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
