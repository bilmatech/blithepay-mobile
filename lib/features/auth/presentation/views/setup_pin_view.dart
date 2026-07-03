import 'package:blithepay/features/common/data/success_args_model.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_event.dart';
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
import '../../../../shared/widgets/background/auth_flow_background.dart';

class SetupOtpView extends StatefulWidget {
  final String email;
  final OtpFlow flow;
  final bool popOnSuccess;

  const SetupOtpView({
    super.key,
    required this.email,
    required this.flow,
    this.popOnSuccess = false,
  });

  @override
  State<SetupOtpView> createState() => _SetupOtpViewState();
}

class _SetupOtpViewState extends State<SetupOtpView> {
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
        SetupPinRequested(email: widget.email, code: code, flow: widget.flow),
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
        if (state.status == AuthStatus.pinSetup) {
          if (widget.popOnSuccess) {
            Navigator.of(context).pop(true);
          } else {
            context.go(
              AppRoutes.success,
              extra: const SuccessArgs(
                title: AppStrings.successful,
                message: AppStrings.anAccounthasbeen,
                buttonLabel: AppStrings.gotToHome,
                nextRoute: AppRoutes.home,
                useAuthBackground: true,
              ),
            );
            context.read<DashboardBloc>().add(const FetchDashboardData());
          }
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
                      const Text(
                        AppStrings.setupDigitPin,
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        AppStrings.setup,
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
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              obscureText: true,
                              onChanged: (value) =>
                                  _onOtpFieldChanged(index, value),
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
                        ),
                      ),
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
