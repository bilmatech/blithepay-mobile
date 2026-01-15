import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaymentConfirmationView extends StatelessWidget {
  const PaymentConfirmationView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pay Fees'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment Confirmation',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.black),
              ),
              const SizedBox(height: 8),
              const Text('Crosscheck payment details'),
              const SizedBox(height: 32),

              // Transaction Details
              _buildDetailRow('Tuition Fee:', 'N300000'),
              const SizedBox(height: 12),
              _buildDetailRow('Exam Fees:', 'N500000'),
              const SizedBox(height: 12),
              _buildDetailRow('Library Fees:', 'N10000'),
              const SizedBox(height: 12),
              _buildDetailRow('Tuition Fee:', 'N300000'),
              const SizedBox(height: 12),
              _buildDetailRow('Exam Fee:', 'N50000'),
              const SizedBox(height: 12),
              _buildDetailRow('Library Fees', 'N10000'),
              const SizedBox(height: 40),

              // Action Buttons
              PrimaryButton(
                label: 'Confrim Payment',
                onPressed: () {
                  // Here you can pass _selectedFees to your payment logic
                  context.go(AppRoutes.feeSuccess);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.surface,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
