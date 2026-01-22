import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/features/fees/presentation/views/widgets/student_card_container_widget.dart';
import 'package:blithepay/features/students/data/models/student_model.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/secondary_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaymentSuccessView extends StatelessWidget {
  const PaymentSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        automaticallyImplyActions: false,
        title: const Text('Pay Fees'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              //   Success Indicator
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 16),
              const Text(
                'Payment Successful',
                style: TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '-N1,000,000',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // Transaction Details
              SizedBox(
                height: 200,
                child: StudentCardContainerWidget(
                  margin: EdgeInsets.zero,
                  student: StudentModel(
                    id: '1',
                    name: 'Adebayo Oluwaferanmi',
                    studentId: '7ytf5675dm',
                    class_: 'Primary 3',
                    school: 'Seaman International Nursery & Primary School',
                    feeStatus: 'Fee Paid',
                    amountDue: 300000,
                  ),
                ),
              ),
              //  _buildDetailRow('Fee:', 'Tuition Fee'),
              const SizedBox(height: 12),
              _buildDetailRow('Student:', 'Aishat Abdul Yusuf'),
              // const SizedBox(height: 12),
              //  _buildDetailRow('Method:', 'Wallet Balance'),
              const SizedBox(height: 12),
              _buildDetailRow('Total:', 'N1,000,000'),
              const SizedBox(height: 12),
              _buildDetailRow('Date:', '11/12/25. 09:22'),

              const SizedBox(height: 12),
              _buildDetailRow('Reference:', '98yuy6434678gfe54'),
              const SizedBox(height: 40),

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
                      child: const Text('Done'),
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
