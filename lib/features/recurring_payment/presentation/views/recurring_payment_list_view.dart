import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../domain/entities/recurring_payment.dart';

class RecurringPaymentListView extends StatefulWidget {
  const RecurringPaymentListView({super.key});

  @override
  State<RecurringPaymentListView> createState() =>
      _RecurringPaymentListViewState();
}

class _RecurringPaymentListViewState extends State<RecurringPaymentListView> {
  // Dummy data
  final List<RecurringPayment> recurringPayments = [
    RecurringPayment(
      id: '1',
      biller: 'NEPA',
      type: 'Postpaid',
      meterNumber: 'HM12345678',
      amount: 10000,
      duration: 'Monthly',
      startDate: DateTime.now(),
      nextPaymentDate: DateTime.now().add(const Duration(days: 30)),
      isActive: true,
      totalPayments: 12,
      paymentsRemaining: 8,
      createdAt: DateTime.now(),
    ),
    RecurringPayment(
      id: '2',
      biller: 'Dstv',
      type: 'Prepaid',
      meterNumber: 'DS987654321',
      amount: 7500,
      duration: 'Monthly',
      startDate: DateTime.now().subtract(const Duration(days: 15)),
      nextPaymentDate: DateTime.now().add(const Duration(days: 15)),
      isActive: true,
      totalPayments: 6,
      paymentsRemaining: 4,
      createdAt: DateTime.now(),
    ),
    RecurringPayment(
      id: '3',
      biller: 'Gotv',
      type: 'Prepaid',
      meterNumber: 'GT456789123',
      amount: 3500,
      duration: 'Monthly',
      startDate: DateTime.now().subtract(const Duration(days: 45)),
      nextPaymentDate: DateTime.now().add(const Duration(days: 5)),
      isActive: false,
      totalPayments: 3,
      paymentsRemaining: 0,
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Recurring Payments'),
        centerTitle: true,
      ),
      body: recurringPayments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment, size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text('No Recurring Payments', style: AppTextStyles.h3),
                  const SizedBox(height: 8),
                  Text(
                    'Create a recurring payment to get started',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 200,
                    child: PrimaryButton(
                      label: 'Create Payment',
                      onPressed: () {
                        // TODO: Navigate to create recurring payment
                      },
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: recurringPayments.length,
              itemBuilder: (context, index) {
                final payment = recurringPayments[index];
                return RecurringPaymentCard(payment: payment);
              },
            ),
    );
  }
}

class RecurringPaymentCard extends StatelessWidget {
  final RecurringPayment payment;

  const RecurringPaymentCard({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: payment.isActive ? AppColors.primary : AppColors.border,
          width: payment.isActive ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(payment.biller, style: AppTextStyles.bodyLarge),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: payment.isActive ? AppColors.success : AppColors.error,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  payment.isActive ? 'Active' : 'Inactive',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'Type', value: payment.type),
          _InfoRow(label: 'Meter', value: payment.meterNumber),
          _InfoRow(
            label: 'Amount',
            value: '₦${payment.amount.toStringAsFixed(2)}',
          ),
          _InfoRow(label: 'Duration', value: payment.duration),
          const SizedBox(height: 12),
          if (payment.nextPaymentDate != null)
            Text(
              'Next Payment: ${DateFormat('MMM dd, yyyy').format(payment.nextPaymentDate!)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          if (payment.paymentsRemaining != null &&
              payment.paymentsRemaining! > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Payments remaining: ${payment.paymentsRemaining}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    // TODO: Edit payment
                  },
                  style: TextButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    // TODO: Delete payment
                  },
                  style: TextButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Delete',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(value, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
