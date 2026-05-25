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
      // if (kDebugMode) {
      //   switch (widget.flow) {
      //     case OtpFlow.signup:
      //       context.go(
      //         AppRoutes.success,
      //         extra: SuccessArgs(
      //           title: AppStrings.verificationSuccess,
      //           message: AppStrings.anAccounthasbeen,
      //           buttonLabel: AppStrings.setupPin,
      //           nextRoute: AppRoutes.setupOtp,
      //           nextExtra: {
      //             'email': widget.email,
      //             'flow': OtpFlow.signup,
      //             'fromProfile': widget.fromProfile,
      //           },
      //           useAuthBackground: true,
      //         ),
      //       );
      //       break;
      //     case OtpFlow.forgotPassword:
      //       context.push(
      //         AppRoutes.resetPassword,
      //         extra: {'email': widget.email, 'fromProfile': widget.fromProfile},
      //       );
      //       break;
      //     case OtpFlow.verifyEmail:
      //       context.go(
      //         AppRoutes.success,
      //         extra: SuccessArgs(
      //           title: AppStrings.verificationSuccess,
      //           message: AppStrings.anAccounthasbeen,
      //           buttonLabel: AppStrings.logIn,
      //           nextRoute: AppRoutes.login,
      //           nextExtra: {'email': widget.email, 'flow': OtpFlow.verifyEmail},
      //         ),
      //       );
      //       break;
      //   }
      //   return;
      // }

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
    final fieldWidth = ((screenWidth - 80) / 6).clamp(44.0, 56.0);

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
        showBackButton: false,
        // background: const AuthFlowBackground(),
        body: AuthBackgroundWrapper(
          child: BlocBuilder<AuthBloc, AuthState>(
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
                      const SizedBox(height: 24),
                      if (widget.flow == OtpFlow.signup) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Step 2 of 3',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Verification',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                      Container(
                        width: 128,
                        height: 128,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/message.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // BackArrowButtonIcon(),
                      const SizedBox(height: 24),
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
                                  decoration: InputDecoration(
                                    counterText: '',
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),

                              // 👇 spacing BETWEEN fields
                              if (index != 5) const SizedBox(width: 12),
                            ],
                          );
                        }),
                      ),
                      const SizedBox(height: 32),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: _canResend ? _handleResendOtp : null,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Text(
                              //   _canResend
                              //       ? AppStrings.resendCode
                              //       : '${AppStrings.resendCode} (${_secondsRemaining}s)',
                              //   style: AppTextStyles.link.copyWith(
                              //     color: _canResend
                              //         ? AppColors.primary
                              //         : AppColors.textSecondary,
                              //   ),
                              // ),
                              Text(
                                _canResend
                                    ? AppStrings.resendCode
                                    : '${_secondsRemaining}s',

                                style: AppTextStyles.link.copyWith(
                                  color: _canResend
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                              ),
                              if (!_canResend) ...[
                                const Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                              ],
                            ],
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
      ),
    );
  }
}
