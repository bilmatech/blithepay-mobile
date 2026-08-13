import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import 'package:blithepay/shared/widgets/step_progress_indicator.dart';
import 'package:blithepay/features/common/data/success_args_model.dart';
import '../../../../shared/widgets/background/auth_flow_background.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_event.dart';

class SetupOtpView extends StatefulWidget {
  final String email;
  final OtpFlow flow;
  final bool popOnSuccess;
  final String? verificationCode;

  const SetupOtpView({
    super.key,
    required this.email,
    required this.flow,
    this.popOnSuccess = false,
    this.verificationCode,
  });

  @override
  State<SetupOtpView> createState() => _SetupOtpViewState();
}

class _SetupOtpViewState extends State<SetupOtpView> {
  late List<TextEditingController> _otpControllers;
  late List<FocusNode> _focusNodes;
  String? _firstPin;

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(4, (_) => TextEditingController(text: ' '));
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
    final code = _otpControllers.map((c) => c.text.trim()).join();

    if (code.length == 4) {
      if (_firstPin == null) {
        setState(() {
          _firstPin = code;
          for (var controller in _otpControllers) {
            controller.text = ' ';
          }
        });
        _focusNodes[0].requestFocus();
      } else {
        if (code == _firstPin) {
          if (widget.flow == OtpFlow.pinReset) {
            final verificationCode = widget.verificationCode ?? '';
            if (verificationCode.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Verification code is missing. Please try again.'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.redAccent,
                ),
              );
              return;
            }
            context.read<AuthBloc>().add(
              FinalizePinResetRequested(
                verificationCode: verificationCode,
                newPin: code,
              ),
            );
          } else {
            context.read<AuthBloc>().add(
              SetupPinRequested(email: widget.email, code: code, flow: widget.flow),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PINs do not match. Please try again.'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.redAccent,
            ),
          );
          setState(() {
            _firstPin = null;
            for (var controller in _otpControllers) {
              controller.text = ' ';
            }
          });
          _focusNodes[0].requestFocus();
        }
      }
    }
  }

  void _onOtpFieldChanged(int index, String value) {
    final cleanValue = value.replaceAll(' ', '');

    // HANDLE PASTE
    if (cleanValue.length > 1) {
      final chars = cleanValue.split('');

      for (int i = 0; i < _otpControllers.length; i++) {
        _otpControllers[i].text = i < chars.length ? chars[i] : ' ';
      }

      _focusNodes.last.requestFocus();
      _handleVerifyOtp();
      return;
    }

    // BACKSPACE / DELETE
    if (value.isEmpty) {
      _otpControllers[index].text = ' ';
      if (index > 0) {
        _otpControllers[index - 1].text = ' ';
        _focusNodes[index - 1].requestFocus();
      }
      return;
    }

    // NORMAL typing behavior
    if (cleanValue.isNotEmpty) {
      final char = cleanValue.substring(cleanValue.length - 1);
      _otpControllers[index].value = TextEditingValue(
        text: char,
        selection: TextSelection.collapsed(offset: char.length),
      );
      if (index < 3) {
        _focusNodes[index + 1].requestFocus();
      }
      _handleVerifyOtp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.pinSetup) {
          if (widget.popOnSuccess) {
            Navigator.of(context).pop(true);
          } else {
            context.go(
              AppRoutes.success,
              extra: SuccessArgs(
                title: AppStrings.successful,
                message: AppStrings.anAccounthasbeen,
                buttonLabel: AppStrings.gotToHome,
                nextRoute: AppRoutes.enableBiometrics,
                nextExtra: widget.email,
                useAuthBackground: true,
              ),
            );
            context.read<DashboardBloc>().add(const FetchDashboardData());
          }
        }

        if (state.status == AuthStatus.pinResetSuccess) {
          context.go(
            AppRoutes.success,
            extra: SuccessArgs(
              title: 'PIN reset successful',
              message: 'Your transaction PIN has been updated successfully.',
              buttonLabel: 'Back to profile',
              nextRoute: AppRoutes.profile,
              useAuthBackground: true,
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
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (widget.flow == OtpFlow.signup) ...[
                        const StepProgressIndicator(
                          currentStep: 3,
                          totalSteps: 3,
                          label: 'Security',
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
                            'assets/images/key.png',
                            width: 48,
                            height: 48,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        _firstPin == null ? AppStrings.setupDigitPin : 'Confirm Transaction PIN',
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _firstPin == null ? AppStrings.setup : 'Re-enter your 4 digit PIN to confirm.',
                        style: AppTextStyles.bodyRegular,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 36),
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
                              keyboardType: TextInputType.number,

                              maxLength: 1,
                              maxLengthEnforcement: MaxLengthEnforcement.none,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9\s]')),
                              ],
                              obscureText: true,
                              onChanged: (value) => _onOtpFieldChanged(index, value),
                              style: AppTextStyles.h3.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                counter: const Offstage(),
                                fillColor: AppColors.surface,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppColors.border),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppColors.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_firstPin != null) ...[
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _firstPin = null;
                              for (var controller in _otpControllers) {
                                controller.text = ' ';
                              }
                            });
                            _focusNodes[0].requestFocus();
                          },
                          child: const Text(
                            'Start Over',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 48),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: PrimaryButton(
                          label: AppStrings.continueS,
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
