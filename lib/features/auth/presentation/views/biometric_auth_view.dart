import 'package:blithepay/core/navigation/index.dart';
import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_strings.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:blithepay/shared/widgets/buttons/secondary_outlined_button.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:flutter/material.dart';

class BiometricAuthView extends StatelessWidget {
  const BiometricAuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showBackButton: false,
      // background: const AuthFlowBackground(),
      body: SafeArea(
        child: Container(
          color: AppColors.white,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Text(AppStrings.welcomeBack, style: AppTextStyles.h2),
              const SizedBox(height: 8),
              // const Text('Adewale', style: AppTextStyles.headingLarge),
              // const SizedBox(height: 10),
              const Text(
                AppStrings.welcomeBackSubtitle,
                style: AppTextStyles.bodyRegular,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: .12),
                        width: 4,
                      ),
                    ),
                  ),
                  Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.18),
                        width: 2,
                      ),
                    ),
                  ),
                  Container(
                    width: 150,
                    height: 150,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.fingerprint,
                        color: AppColors.primary,
                        size: 60,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'TOUCH SENSOR TO LOGIN',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 20),
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: AppStrings.continueS,
                onPressed: () {
                  // if (kDebugMode) {
                  //   context.go(AppRoutes.linkedStudents);
                  //   context.read<DashboardBloc>().add(
                  //     const FetchDashboardData(),
                  //   );
                  // }
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SecondaryOutlinedButton(
                      label: AppStrings.usePasswordInstead,
                      onPressed: () => context.go(AppRoutes.login),
                      borderColor: AppColors.border,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
