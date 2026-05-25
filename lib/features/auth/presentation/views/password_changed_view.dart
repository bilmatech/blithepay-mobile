import 'package:blithepay/shared/widgets/background/auth_flow_background.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/layouts/app_scaffold.dart';

class PasswordChangedView extends StatelessWidget {
  final bool fromProfile;
  const PasswordChangedView({super.key, this.fromProfile = false});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showBackButton: false,
      body: AuthBackgroundWrapper(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/success.png',
                        width: 72,
                        height: 72,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    AppStrings.passwordChanged,
                    style: AppTextStyles.h2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    fromProfile
                        ? 'You can now log in with your new details'
                        : AppStrings.passwordChangedDesc,
                    style: AppTextStyles.bodyRegular,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  PrimaryButton(
                    label: fromProfile ? 'Go Back' : AppStrings.returnToLogIn,
                    onPressed: () => fromProfile
                        ? context.go(AppRoutes.profile)
                        : context.go(AppRoutes.login),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
