import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AccountDetailsWidget extends StatelessWidget {
  final String accountName;
  final String acctNo;
  const AccountDetailsWidget({
    super.key,
    required this.accountName,
    required this.acctNo,
  });

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Account Number", style: AppTextStyles.bodySmall),
                    const SizedBox(height: 6),
                    Text(acctNo, style: AppTextStyles.bodyLarge),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: acctNo));

                  final messenger = ScaffoldMessenger.of(context);
                  messenger.clearSnackBars();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text("Account number copied"),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Account Name", style: AppTextStyles.bodySmall),
              const SizedBox(height: 6),
              Text(accountName, style: AppTextStyles.bodyLarge),
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
