import 'package:blithepay/core/utils/validators.dart';
import 'package:blithepay/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:blithepay/features/profile/presentation/bloc/profile_event.dart';
import 'package:blithepay/features/profile/presentation/bloc/profile_state.dart';
import 'package:blithepay/shared/widgets/inputs/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/layouts/app_scaffold.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _oldPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleResetPassword() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileBloc>().add(
        ChangePasswordRequested(
          oldPassword: _oldPasswordController.text,
          newPassword: _newPasswordController.text,
          confirmPassword: _confirmPasswordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        //  if (state.status == AuthStatus.passwordReset) {
        context.canPop();
        // } else if (state.status == AuthStatus.error) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: Text(state.errorMessage ?? 'Failed to reset password'),
        //     ),
        //   );
        // }
      },
      child: AppScaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Change Password'),
          centerTitle: true,
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    AppTextField(
                      label: AppStrings.oldPassword,
                      hint: AppStrings.oldPassword,
                      controller: _oldPasswordController,
                      obscureText: true,
                      showPasswordToggle: true,
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 16),
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
                      // isLoading: state.status == AuthStatus.loading,
                      // isEnabled: state.status != AuthStatus.loading,
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
