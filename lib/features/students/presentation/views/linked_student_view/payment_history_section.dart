import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:blithepay/features/dashboard/presentation/widgets/recent_transactions.dart';
import 'package:blithepay/features/wallet/data/models/wallet_transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaymentHistorySection extends StatelessWidget {
  const PaymentHistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Payment History:', style: AppTextStyles.bodyLarge),
            GestureDetector(
              onTap: () {
                context.push(AppRoutes.feeTransactions);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      'See All',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),

            // Row(
            //   children: [
            //     // Filter button with search
            //     AppOutlinedIconButton(
            //       onPressed: () => showFilterPopup<String>(
            //         context: context,
            //         items: [
            //           'Successful',
            //           'Failed',
            //           'Pending',
            //           'Withdrawal',
            //           'Fee Payment',
            //           'Deposit',
            //         ],
            //         selectedValue: currentFilter,
            //         onItemSelected: (value) =>
            //             setState(() => currentFilter = value),
            //         enableSearch: false,
            //       ),
            //       label: 'Filter',
            //       icon: Icons.tune,
            //     ),
            //     const SizedBox(width: 8),

            //     // Sort button without search
            //     AppOutlinedIconButton(
            //       onPressed: () => showFilterPopup<String>(
            //         context: context,
            //         items: [
            //           'A-Z',
            //           'Z-A',
            //           'Highest - Lowest',
            //           'Lowest - Highest',
            //           'Most Recent',
            //           'Oldest',
            //         ],
            //         selectedValue: currentSort,
            //         onItemSelected: (value) =>
            //             setState(() => currentSort = value),
            //         enableSearch: false, // no search for sort
            //       ),
            //       label: 'Sort by',
            //       icon: Icons.sort,
            //     ),
            //   ],
            // ),
          ],
        ),
        const SizedBox(height: 24),

        // Transaction table
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: transactions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return TransactionContainer(transaction: transaction);
          },
        ),
      ],
    );
  }
}

final transactions = [
  WalletTransactionModel(
    amount: '300',
    status: 'success',
    id: 'cmlqkb0qr003e0vpczzqhii7l',
    name: 'Tuition fee',
    walletId: 'cmljgzu8w00070vp3yy5udkc8',
    fees: '10',
    netAmount: '198',
    reference: '1771330263964dmgr24pmlqkayzg',
    type: 'Deposit',
    flow: '',
    transactionAt: '2026-02-17T12:11:06.242Z',
    processedAt: '2026-02-17T12:11:07.027Z',
    isDeleted: false,
    createdAt: '2026-02-17T12:11:07.028Z',
    updatedAt: '2026-02-17T12:11:06.243Z',
  ),
  WalletTransactionModel(
    amount: '200',
    status: 'success',
    id: 'cmlqkb0qr003e0vpczzqhii7l',
    name: 'Tuition fee',
    walletId: 'cmljgzu8w00070vp3yy5udkc8',
    fees: '10',
    netAmount: '',
    reference: '1771330263964dmgr24pmlqkayzg',
    type: 'Deposit',
    flow: '',
    transactionAt: '2026-02-17T12:11:06.242Z',
    processedAt: '2026-02-17T12:11:07.027Z',
    isDeleted: false,
    createdAt: '2026-02-17T12:11:07.028Z',
    updatedAt: '2026-02-17T12:11:06.243Z',
  ),
];
