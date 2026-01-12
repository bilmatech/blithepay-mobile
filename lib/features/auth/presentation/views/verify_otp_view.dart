import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class VerifyOtpView extends StatefulWidget {
  final String email;
  final OtpFlow flow;

  const VerifyOtpView({super.key, required this.email, required this.flow});

  @override
  State<VerifyOtpView> createState() => _VerifyOtpViewState();
}

class _VerifyOtpViewState extends State<VerifyOtpView> {
  late List<TextEditingController> _otpControllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(4, (_) => TextEditingController());
    _focusNodes = List.generate(4, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleVerifyOtp() {
    final code = _otpControllers.map((c) => c.text).join();

    if (code.length == 4) {
      context.read<AuthBloc>().add(
        VerifyOtpRequested(email: widget.email, code: code, flow: widget.flow),
      );
    }
  }

  void _onOtpFieldChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.otpVerified) {
          switch (widget.flow) {
            case OtpFlow.signup:
              context.go(AppRoutes.login);
              break;

            case OtpFlow.forgotPassword:
              context.push(AppRoutes.resetPassword, extra: widget.email);
              break;
          }
        } else if (state.status == AuthStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Verification failed'),
            ),
          );
        }
      },
      child: AppScaffold(
        showBackButton: false,
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      AppStrings.enterConfirmationCode,
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: '${AppStrings.codeSentTo}\n',
                        style: AppTextStyles.bodyRegular,
                        children: [
                          TextSpan(
                            text: widget.email,
                            style: AppTextStyles.bodyRegular.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        4,
                        (index) => SizedBox(
                          width: 60,
                          height: 60,
                          child: TextField(
                            controller: _otpControllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) =>
                                _onOtpFieldChanged(index, value),
                            style: AppTextStyles.h3,
                            decoration: InputDecoration(
                              counter: const Offstage(),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: GestureDetector(
                        onTap: () {},
                        child: const Text(
                          AppStrings.resendCode,
                          style: AppTextStyles.link,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    PrimaryButton(
                      label: AppStrings.verify,
                      onPressed: _handleVerifyOtp,
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
