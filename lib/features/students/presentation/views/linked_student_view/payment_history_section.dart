import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:blithepay/core/utils/helpers.dart';
import 'package:blithepay/features/students/data/models/student_transaction_model.dart';
import 'package:blithepay/features/students/data/models/verify_student_model.dart';
import 'package:blithepay/features/students/presentation/bloc/students_state.dart';
import 'package:blithepay/features/students/presentation/bloc/transaction_bloc.dart/transaction_bloc.dart';
import 'package:blithepay/features/students/presentation/bloc/transaction_bloc.dart/transaction_event.dart';
import 'package:blithepay/features/students/presentation/bloc/transaction_bloc.dart/transaction_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PaymentHistorySection extends StatelessWidget {
  final VerifiedStudentModel student;

  const PaymentHistorySection({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    // Trigger the API call for this student
    context.read<StudentTransactionsBloc>().add(
      GetPaymentHistoryEvent(studentId: student.id, refresh: true),
    );

    return BlocBuilder<StudentTransactionsBloc, StudentTransactionState>(
      builder: (context, state) {
        List<StudentTransactionModel> transactions = [];

        bool isLoading = state is StudentsLoading;
        if (state is StudentTransactionLoaded) {
          transactions = state.studentTransaction.take(4).toList();
          ;
          print("$transactions");
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Payment History:', style: AppTextStyles.bodyLarge),
                GestureDetector(
                  onTap: () {
                    context.push(AppRoutes.feeTransactions, extra: student);
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
              ],
            ),
            const SizedBox(height: 24),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (transactions.isEmpty)
              const Text('No payment history available.')
            else
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: transactions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return StudentTransactionContainer(transaction: transaction);
                },
              ),
          ],
        );
      },
    );
  }
}

class StudentTransactionContainer extends StatelessWidget {
  final StudentTransactionModel transaction;

  const StudentTransactionContainer({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.studentTransactionDetail, extra: transaction);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.lightBack.withAlpha(13),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side: icon + description
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Wrap description + date in Flexible to prevent overflow
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.description,
                          style: AppTextStyles.headingSmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Helpers.formatDate(transaction.transactionAt),
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Right side: amount + status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 100, // constrain width to avoid overflow
                  child: Text(
                    Helpers.formattedAmount(transaction.amount),
                    style: AppTextStyles.headingSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.status,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: transaction.status.toLowerCase() == 'success'
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} // class PaymentHistorySection extends StatelessWidget {

//   const PaymentHistorySection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text('Payment History:', style: AppTextStyles.bodyLarge),
//             GestureDetector(
//               onTap: () {
//                 context.push(AppRoutes.feeTransactions);
//               },
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: AppColors.primary),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     Text(
//                       'See All',
//                       style: AppTextStyles.bodySmall.copyWith(
//                         color: AppColors.primary,
//                       ),
//                     ),
//                     const SizedBox(width: 4),
//                     const Icon(
//                       Icons.arrow_forward,
//                       color: AppColors.primary,
//                       size: 16,
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // Row(
//             //   children: [
//             //     // Filter button with search
//             //     AppOutlinedIconButton(
//             //       onPressed: () => showFilterPopup<String>(
//             //         context: context,
//             //         items: [
//             //           'Successful',
//             //           'Failed',
//             //           'Pending',
//             //           'Withdrawal',
//             //           'Fee Payment',
//             //           'Deposit',
//             //         ],
//             //         selectedValue: currentFilter,
//             //         onItemSelected: (value) =>
//             //             setState(() => currentFilter = value),
//             //         enableSearch: false,
//             //       ),
//             //       label: 'Filter',
//             //       icon: Icons.tune,
//             //     ),
//             //     const SizedBox(width: 8),

//             //     // Sort button without search
//             //     AppOutlinedIconButton(
//             //       onPressed: () => showFilterPopup<String>(
//             //         context: context,
//             //         items: [
//             //           'A-Z',
//             //           'Z-A',
//             //           'Highest - Lowest',
//             //           'Lowest - Highest',
//             //           'Most Recent',
//             //           'Oldest',
//             //         ],
//             //         selectedValue: currentSort,
//             //         onItemSelected: (value) =>
//             //             setState(() => currentSort = value),
//             //         enableSearch: false, // no search for sort
//             //       ),
//             //       label: 'Sort by',
//             //       icon: Icons.sort,
//             //     ),
//             //   ],
//             // ),
//           ],
//         ),
//         const SizedBox(height: 24),

//         // Transaction table
//         ListView.separated(
//           physics: const NeverScrollableScrollPhysics(),
//           shrinkWrap: true,
//           itemCount: transactions.length,
//           separatorBuilder: (_, __) => const SizedBox(height: 12),
//           itemBuilder: (context, index) {
//             final transaction = transactions[index];
//             return TransactionContainer(transaction: transaction);
//           },
//         ),
//       ],
//     );
//   }
// }
