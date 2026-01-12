import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/layouts/app_scaffold.dart';

class PasswordChangedView extends StatelessWidget {
  const PasswordChangedView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showBackButton: false,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.white,
                  size: 60,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                AppStrings.passwordChanged,
                style: AppTextStyles.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                AppStrings.passwordChangedDesc,
                style: AppTextStyles.bodyRegular,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              PrimaryButton(
                label: AppStrings.returnToLogIn,
                onPressed: () => context.go(AppRoutes.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
