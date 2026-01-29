import 'dart:async';

import 'package:blithepay/features/common/data/success_args_model.dart';
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
  late Timer _timer;
  int _secondsRemaining = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(6, (_) => TextEditingController());
    _focusNodes = List.generate(6, (_) => FocusNode());
    _startCountdown();
  }

  @override
  void dispose() {
    _timer.cancel();
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

    if (code.length == 6) {
      if (widget.flow == OtpFlow.forgotPassword) {
        context.read<AuthBloc>().add(
          VerifyForgotPasswordOtpRequested(
            email: widget.email,
            code: code,
            flow: widget.flow,
          ),
        );
        return;
      }
      context.read<AuthBloc>().add(
        VerifyOtpRequested(email: widget.email, code: code, flow: widget.flow),
      );
    }
  }

  void _onOtpFieldChanged(int index, String value) {
    if (index == 0 && value.length > 1) {
      final chars = value.split('');

      for (int i = 0; i < _otpControllers.length; i++) {
        _otpControllers[i].text = i < chars.length ? chars[i] : '';
      }

      _otpControllers[0].text = chars.isNotEmpty ? chars[0] : '';

      _focusNodes.last.requestFocus();
      _handleVerifyOtp();
      return;
    }
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _startCountdown() {
    _secondsRemaining = 30;
    _canResend = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
        setState(() {
          _canResend = true;
        });
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  void _handleResendOtp() {
    if (!_canResend) return;
    final bloc = context.read<AuthBloc>();
    if (widget.flow == OtpFlow.forgotPassword) {
      bloc.add(
        ResendForgotPasswordOtpRequested(
          email: widget.email,
          flow: widget.flow,
        ),
      );
    } else {
      bloc.add(ResendOtpRequested(email: widget.email, flow: widget.flow));
    }
    _startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.otpVerified) {
          switch (widget.flow) {
            case OtpFlow.signup:
              context.go(
                AppRoutes.success,
                extra: SuccessArgs(
                  title: AppStrings.verificationSuccess,
                  message: AppStrings.anAccounthasbeen,
                  buttonLabel: AppStrings.setupPin,
                  nextRoute: AppRoutes.setupOtp,
                  nextExtra: {'email': widget.email, 'flow': OtpFlow.signup},
                ),
              );

              break;

            case OtpFlow.forgotPassword:
              context.push(AppRoutes.resetPassword, extra: widget.email);
              break;

            case OtpFlow.verifyEmail:
              context.go(
                AppRoutes.success,
                extra: SuccessArgs(
                  title: AppStrings.verificationSuccess,
                  message: AppStrings.anAccounthasbeen,
                  buttonLabel: AppStrings.logIn,
                  nextRoute: AppRoutes.login,
                  nextExtra: {
                    'email': widget.email,
                    'flow': OtpFlow.verifyEmail,
                  },
                ),
              );
              break;
          }
        }
      },
      child: AppScaffold(
        showBackButton: false,
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      AppStrings.enterVerificationCode,
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
                      children: List.generate(
                        6,
                        (index) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: SizedBox(
                              height: 56,
                              child: TextField(
                                controller: _otpControllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                style: AppTextStyles.h3,

                                inputFormatters: [
                                  TextInputFormatter.withFunction((
                                    oldValue,
                                    newValue,
                                  ) {
                                    final text = newValue.text.replaceAll(
                                      RegExp(r'\D'),
                                      '',
                                    );

                                    if (index != 0 && text.length > 1) {
                                      return oldValue;
                                    }

                                    if (text.length > 6) {
                                      return oldValue;
                                    }

                                    return TextEditingValue(
                                      text: text,
                                      selection: TextSelection.collapsed(
                                        offset: text.length,
                                      ),
                                    );
                                  }),
                                ],

                                onChanged: (value) =>
                                    _onOtpFieldChanged(index, value),

                                decoration: InputDecoration(
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
                      ),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: GestureDetector(
                        onTap: _canResend ? _handleResendOtp : null,
                        child: Text(
                          _canResend
                              ? AppStrings.resendCode
                              : '${AppStrings.resendCode} (${_secondsRemaining}s)',
                          style: AppTextStyles.link.copyWith(
                            color: _canResend
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: PrimaryButton(
                        label: AppStrings.verify,
                        onPressed: _handleVerifyOtp,
                        isLoading: state.status == AuthStatus.loading,
                        isEnabled: state.status != AuthStatus.loading,
                      ),
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
