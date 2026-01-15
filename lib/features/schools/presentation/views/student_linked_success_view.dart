import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';

class StudentLinkedSucessView extends StatelessWidget {
  final String? message;
  final VoidCallback? onPressed;

  const StudentLinkedSucessView({super.key, this.message, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Link Child'),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://via.placeholder.com/150', // child image url
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Adebowale Anthony Joshua',
                  style: AppTextStyles.bodyRegular.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Successful',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Student linked successfully',
                  style: AppTextStyles.headingMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message ??
                      'You’ve successfully linked the student to your profile. Proceed to home screen.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: 'Go Home',
                  onPressed: onPressed ?? () => context.go('/home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
