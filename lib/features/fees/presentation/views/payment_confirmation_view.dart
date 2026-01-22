import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:blithepay/features/fees/presentation/views/widgets/pin_bottom_sheet_content.dart';
import 'package:blithepay/features/fees/presentation/views/widgets/student_card_container_widget.dart';
import 'package:blithepay/features/students/data/models/student_model.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
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

              // Student Card
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
                    feeStatus: 'Fee Pending',
                    amountDue: 300000,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _buildFeeDetails(),
              const SizedBox(height: 24),

              _buildTotalFeeDetails(),
              const SizedBox(height: 28),

              // Pay Button
              PrimaryButton(
                label: 'Pay',
                onPressed: () async {
                  final result = await _showPinBottomSheet(context);
                  if (result == true) {
                    context.go(AppRoutes.feeSuccess);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeeDetails() {
    final feeItems = [
      {'label': 'Tuition Fee:', 'value': 'N300000'},
      {'label': 'Exam Fees:', 'value': 'N500000'},
      {'label': 'Library Fees:', 'value': 'N10000'},
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.surface,
      ),
      child: Column(
        children: List.generate(feeItems.length * 2 - 1, (index) {
          if (index.isOdd)
            return const Divider(height: 1, color: AppColors.border);
          final item = feeItems[index ~/ 2];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item['label']!, style: AppTextStyles.bodyRegular),
                Text(item['value']!, style: AppTextStyles.bodyRegular),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTotalFeeDetails() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.surface,
      ),
      child: const Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: AppTextStyles.bodyLarge),
                Text('N1,000,000.00', style: AppTextStyles.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showPinBottomSheet(BuildContext context) {
    return showModalBottomSheet<bool>(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const PinBottomSheetContent(),
    );
  }
}
