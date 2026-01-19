import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/features/dashboard/presentation/models/dashboard_model.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/secondary_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TransactionDetailView extends StatelessWidget {
  final TransactionItem? transaction;

  const TransactionDetailView({super.key, this.transaction});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Transactions'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Success Indicator
              // Container(
              //   width: 80,
              //   height: 80,
              //   decoration: const BoxDecoration(
              //     color: AppColors.success,
              //     shape: BoxShape.circle,
              //   ),
              //   child: const Icon(Icons.check, color: Colors.white, size: 40),
              // ),
              // const SizedBox(height: 16),
              Text(
                transaction?.status ?? 'Successful',
                style: const TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                transaction?.amount ?? '+N200,000',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // Transaction Details
              _buildDetailRow('Fee:', transaction?.title ?? 'Tuition Fee'),
              const SizedBox(height: 12),
              //  _buildDetailRow('Student:', 'Aishat Abdul Yusuf'),
              // const SizedBox(height: 12),
              _buildDetailRow('Method:', 'Wallet Balance'),
              const SizedBox(height: 12),
              _buildDetailRow('Date:', transaction?.date ?? '11/12/25. 09:22'),
              const SizedBox(height: 12),
              _buildDetailRow('Reference:', '98yuy6434678gfe54'),
              const SizedBox(height: 12),
              _buildDetailRow('Note:', 'Tuition payment balance...'),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SecondaryOutlinedButton(
                      onPressed: () {},
                      label: 'Download Receipt',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.go('/home');
                      },
                      child: const Text('Repeat Transaction'),
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

  Widget _buildDetailRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.lightBackground,
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
