import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/navigation/index.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/app_bar.dart';
import 'package:blithepay/shared/widgets/layouts/app_text.dart';
import 'package:flutter/material.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final List<TransactionModel> transactions = [
    TransactionModel(
      name: 'Airtime Recharge',
      transactionAt: DateTime(2024, 6, 17, 23, 15),
      amount: 'N3,000',
      netAmount: 'N3,000',
      reference: 'REF001',
      status: TransactionStatus.successful,
      flow: TransactionFlow.outflow,
      type: TransactionType.airtime,
      icon: '📱',
      fees: 0,
    ),
    TransactionModel(
      name: 'Dstv Subscription',
      transactionAt: DateTime(2024, 7, 19, 23, 15),
      amount: 'N3,000',
      netAmount: 'N3,000',
      reference: 'REF002',
      status: TransactionStatus.successful,
      flow: TransactionFlow.outflow,
      type: TransactionType.cable,
      icon: '📺',
      fees: 0,
    ),
    TransactionModel(
      name: 'Electricity',
      transactionAt: DateTime(2024, 6, 17, 23, 15),
      amount: 'N2,000',
      netAmount: 'N2,000',
      reference: 'REF003',
      status: TransactionStatus.successful,
      flow: TransactionFlow.outflow,
      type: TransactionType.electricity,
      icon: '⚡',
      fees: 0,
    ),
    TransactionModel(
      name: 'Electricity',
      transactionAt: DateTime(2024, 6, 17, 23, 15),
      amount: 'N2,000',
      netAmount: 'N2,000',
      reference: 'REF004',
      status: TransactionStatus.failed,
      flow: TransactionFlow.outflow,
      type: TransactionType.electricity,
      icon: '⚡',
      fees: 0,
    ),
    TransactionModel(
      name: 'Airtime Recharge',
      transactionAt: DateTime(2024, 6, 17, 23, 15),
      amount: 'N3,000',
      netAmount: 'N3,000',
      reference: 'REF005',
      status: TransactionStatus.successful,
      flow: TransactionFlow.outflow,
      type: TransactionType.airtime,
      icon: '📱',
      fees: 0,
    ),
  ];
  String sortBy = 'Recent';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppAppBar(title: 'Transactions', showBackButton: false),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filter and Sort Controls
            Row(
              children: [
                const Spacer(),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.tune, size: 20),
                    label: const Text('Filter'),
                    iconAlignment: IconAlignment.end,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_drop_down, size: 20),
                    label: const Text('Sort by'),
                    iconAlignment: IconAlignment.end,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      iconAlignment: IconAlignment.end,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
            const SizedBox(height: 20),
            // Transactions List
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return _TransactionCard(transaction: transaction);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final TransactionModel transaction;

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.transactionDetail, extra: transaction);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  transaction.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodyMd(transaction.name, color: AppColors.textPrimary),
                  CaptionMd(
                    transaction.transactionAt.toLocal().toString(),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                BodyMd(transaction.amount, color: AppColors.textPrimary),
                CaptionMd(
                  transaction.status.name,
                  color: transaction.status == TransactionStatus.successful
                      ? AppColors.success
                      : AppColors.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
