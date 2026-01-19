import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/features/wallet/presentation/widgets/fund_wallet_widgets/account_details_widget.dart';
import 'package:flutter/material.dart';

class BankCardWidget extends StatelessWidget {
  const BankCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bank Icon and Name
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.border,
                ),
                child: const Icon(Icons.account_balance_rounded, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Bank Name", style: AppTextStyles.bodySmall),
                    SizedBox(height: 2),
                    Text("Wema Bank", style: AppTextStyles.bodyLarge),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const AccountDetailsWidget(),
        ],
      ),
    );
  }
}
