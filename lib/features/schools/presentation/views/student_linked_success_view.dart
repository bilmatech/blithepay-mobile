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
        centerTitle: true,
        title: const Text('Link Child'),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 80),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 1),
                  // image: const DecorationImage(
                  //   image: NetworkImage(
                  //     'https://placehold.co', // child image url
                  //   ),
                  //   fit: BoxFit.cover,
                  // ),
                ),
                child: Icon(Icons.person, size: 40),
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
              const SizedBox(height: 16),

              InkWell(
                onTap: () {
                  context.push('/pay-fees');
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.shimmerBase,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    child: Text(
                      'Pay Fees',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
