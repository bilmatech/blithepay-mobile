import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class AccountDetailsWidget extends StatelessWidget {
  const AccountDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account Number
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Account Number", style: AppTextStyles.bodySmall),
                    SizedBox(height: 6),
                    Text("6543567654", style: AppTextStyles.bodyLarge),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {}, // Add copy logic here
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.border,
                  ),
                  child: const Icon(Icons.copy_rounded, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          // Account Name
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Account Name", style: AppTextStyles.bodySmall),
              SizedBox(height: 6),
              Text("Yunas- BlithePay", style: AppTextStyles.bodyLarge),
            ],
          ),
        ],
      ),
    );
  }
}

class InfoBoxWidget extends StatelessWidget {
  final String message;
  const InfoBoxWidget({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }
}
