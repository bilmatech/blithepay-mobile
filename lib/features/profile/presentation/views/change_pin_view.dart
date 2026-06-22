import 'package:blithepay/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:blithepay/features/profile/presentation/bloc/profile_event.dart';
import 'package:blithepay/features/profile/presentation/bloc/profile_state.dart';
import 'package:blithepay/shared/widgets/inputs/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/layouts/app_scaffold.dart';

class ChangePinView extends StatefulWidget {
  const ChangePinView({super.key});

  @override
  State<ChangePinView> createState() => _ChangePinViewState();
}

class _ChangePinViewState extends State<ChangePinView> {
  late TextEditingController _oldPinController;
  late TextEditingController _newPinController;
  late TextEditingController _confirmPinController;
  late TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _oldPinController = TextEditingController();
    _newPinController = TextEditingController();
    _confirmPinController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _oldPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _limitLength(TextEditingController controller, String value) {
    if (value.length > 4) {
      controller.text = value.substring(0, 4);
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    }
  }

  void _handleChangePin() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileBloc>().add(
        ChangePinRequested(
          oldPin: _oldPinController.text,
          newPin: _newPinController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  String? _validatePin(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName cannot be empty';
    }
    if (value.length != 4) {
      return '$fieldName must be exactly 4 digits';
    }
    if (int.tryParse(value) == null) {
      return '$fieldName must contain only numbers';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfilePinChanged) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: AppScaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Change Transaction PIN'),
          centerTitle: true,
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            final isLoading = state is ProfileLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    AppTextField(
                      label: 'Current PIN',
                      hint: 'Enter current 4-digit PIN',
                      controller: _oldPinController,
                      obscureText: true,
                      showPasswordToggle: true,
                      keyboardType: TextInputType.number,
                      onChanged: (val) => _limitLength(_oldPinController, val),
                      validator: (value) => _validatePin(value, 'Current PIN'),
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      label: 'New PIN',
                      hint: 'Enter new 4-digit PIN',
                      controller: _newPinController,
                      obscureText: true,
                      showPasswordToggle: true,
                      keyboardType: TextInputType.number,
                      onChanged: (val) => _limitLength(_newPinController, val),
                      validator: (value) => _validatePin(value, 'New PIN'),
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      label: 'Confirm New PIN',
                      hint: 'Re-enter new 4-digit PIN',
                      controller: _confirmPinController,
                      obscureText: true,
                      showPasswordToggle: true,
                      keyboardType: TextInputType.number,
                      onChanged: (val) => _limitLength(_confirmPinController, val),
                      validator: (value) {
                        final pinErr = _validatePin(value, 'Confirm New PIN');
                        if (pinErr != null) return pinErr;
                        if (value != _newPinController.text) {
                          return 'Confirm PIN does not match New PIN';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      label: 'Password',
                      hint: 'Enter your account password',
                      controller: _passwordController,
                      obscureText: true,
                      showPasswordToggle: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 48),
                    PrimaryButton(
                      label: 'Change PIN',
                      onPressed: _handleChangePin,
                      isLoading: isLoading,
                      isEnabled: !isLoading,
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
