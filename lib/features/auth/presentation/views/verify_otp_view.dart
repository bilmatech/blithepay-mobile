import 'dart:async';

import 'package:blithepay/features/common/data/success_args_model.dart';
import 'package:blithepay/shared/widgets/background/auth_flow_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import 'package:blithepay/shared/widgets/step_progress_indicator.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class VerifyOtpView extends StatefulWidget {
  final String email;
  final OtpFlow flow;
  final bool fromProfile;

  const VerifyOtpView({
    super.key,
    required this.email,
    required this.flow,
    this.fromProfile = false,
  });

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
    //  HANDLE PASTE (6-digit or more)
    if (value.length > 1) {
      final chars = value.split('');

      for (int i = 0; i < _otpControllers.length; i++) {
        _otpControllers[i].text = i < chars.length ? chars[i] : '';
      }

      _focusNodes.last.requestFocus();
      _handleVerifyOtp();
      return;
    }

    // NORMAL typing behavior
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
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = 48.0; // 24 on each side
    final spacing = screenWidth < 360 ? 6.0 : 8.0;
    final totalSpacing = spacing * 5;
    // Calculate precise field width based on actual screen size and padding/spacing
    final fieldWidth = ((screenWidth - horizontalPadding - totalSpacing - 4) / 6).clamp(38.0, 56.0);



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
                  nextExtra: {
                    'email': widget.email,
                    'flow': OtpFlow.signup,
                    'fromProfile': widget.fromProfile,
                  },
                ),
              );

              break;

            case OtpFlow.forgotPassword:
              context.push(
                AppRoutes.resetPassword,
                extra: {
                  'email': widget.email,
                  'fromProfile': widget.fromProfile,
                },
              );
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
        if (state.status == AuthStatus.error) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? ''),
                behavior: SnackBarBehavior.floating,
              ),
            );
        }
      },
      child: AppScaffold(
        showBackButton: true,
        body: AuthBackgroundWrapper(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (widget.flow == OtpFlow.signup) ...[
                        const StepProgressIndicator(
                          currentStep: 2,
                          totalSteps: 3,
                          label: 'Verification',
                        ),
                        const SizedBox(height: 36),
                      ] else ...[
                        const SizedBox(height: 24),
                      ],
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/message.png',
                            width: 48,
                            height: 48,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
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
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(6, (index) {
                          return Row(
                            children: [
                              SizedBox(
                                width: fieldWidth,
                                height: 56,
                                child: TextField(
                                  controller: _otpControllers[index],
                                  focusNode: _focusNodes[index],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  maxLength: 1,
                                  maxLengthEnforcement:
                                      MaxLengthEnforcement.none,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (value) =>
                                      _onOtpFieldChanged(index, value),
                                  style: AppTextStyles.h3.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    isDense: true,
                                    fillColor: AppColors.surface,
                                    filled: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: AppColors.border,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: AppColors.border,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: AppColors.primary,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // spacing BETWEEN fields
                              if (index != 5) SizedBox(width: spacing),
                            ],
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: GestureDetector(
                          onTap: _canResend ? _handleResendOtp : null,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _canResend
                                    ? AppStrings.resendCode
                                    : '${AppStrings.resendCode} in ',
                                style: AppTextStyles.link.copyWith(
                                  color: _canResend
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  decoration: _canResend
                                      ? TextDecoration.underline
                                      : TextDecoration.none,
                                ),
                              ),
                              if (!_canResend) ...[
                                Text(
                                  '${_secondsRemaining}s',
                                  style: AppTextStyles.bodyRegular.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
      ),
    );
  }
}
