import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';

class SuccessView extends StatelessWidget {
  final String title;
  final String message;
  final String buttonLabel;
  final String nextRoute;
  final Object? nextExtra;

  const SuccessView({
    super.key,
    required this.title,
    required this.message,
    this.buttonLabel = 'My Dashboard',
    required this.nextRoute,
    this.nextExtra,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 24),
                Text(title,
                    style: AppTextStyles.headingLarge,
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: buttonLabel,
                  onPressed: () {
                    context.go(nextRoute, extra: nextExtra);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
