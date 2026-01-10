import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class StudentCard extends StatelessWidget {
  final String name;
  final String grade;
  final double balance;
  final VoidCallback onTap;

  const StudentCard({
    super.key,
    required this.name,
    required this.grade,
    required this.balance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: AppTextStyles.h4),
            const SizedBox(height: 4),
            Text(grade, style: AppTextStyles.bodySmall),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Outstanding Balance', style: AppTextStyles.bodySmall),
                Text('₦${balance.toStringAsFixed(2)}', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

