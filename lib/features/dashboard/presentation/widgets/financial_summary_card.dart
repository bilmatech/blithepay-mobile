import 'dart:ui';

import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class FinancialSummaryCard extends StatefulWidget {
  final String totalOutstanding;
  final String nextDueDate;
  final String walletBalance;
  final String selectedChild;

  const FinancialSummaryCard({
    super.key,
    required this.totalOutstanding,
    required this.nextDueDate,
    required this.walletBalance,
    required this.selectedChild,
  });

  @override
  State<FinancialSummaryCard> createState() => _FinancialSummaryCardState();
}

class _FinancialSummaryCardState extends State<FinancialSummaryCard> {
  bool _balanceVisible = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Spacer(),
                  IconButton(
                    icon: Icon(
                      _balanceVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _balanceVisible = !_balanceVisible),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                _balanceVisible ? 'N200,000.32' : '•••••••••',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Text(
                'Current Balance',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              const SizedBox(height: 8),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.1,
                  ), // semi-transparent glass color
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                  ),
                  onPressed: () {
                    context.push(AppRoutes.fundWallet);
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Fund Wallet'),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),

          // Bottom-right image
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              'assets/images/dashboard.png',
              width: 80,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
      // Column(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
      //     Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       children: [
      //         Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             Text(
      //               'Total Outstanding Fees:',
      //               style: AppTextStyles.bodySmall.copyWith(
      //                 color: AppColors.white,
      //               ),
      //             ),
      //             const SizedBox(height: 8),
      //             Text(
      //               totalOutstanding,
      //               style: AppTextStyles.headingMedium.copyWith(
      //                 color: AppColors.white,
      //               ),
      //             ),
      //           ],
      //         ),
      //         Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             Text(
      //               'Next Due Date:',
      //               style: AppTextStyles.bodySmall.copyWith(
      //                 color: AppColors.white,
      //               ),
      //             ),
      //             const SizedBox(height: 8),
      //             Text(
      //               nextDueDate,
      //               style: AppTextStyles.headingSmall.copyWith(
      //                 color: AppColors.white,
      //               ),
      //             ),
      //           ],
      //         ),
      //       ],
      //     ),
      //     const SizedBox(height: 24),
      //     Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       children: [
      //         Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             Text(
      //               'Wallet Balance:',
      //               style: AppTextStyles.bodySmall.copyWith(
      //                 color: AppColors.white,
      //               ),
      //             ),
      //             const SizedBox(height: 8),
      //             Text(
      //               walletBalance,
      //               style: AppTextStyles.headingSmall.copyWith(
      //                 color: AppColors.white,
      //               ),
      //             ),
      //           ],
      //         ),
      //         Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             Text(
      //               'Select Child:',
      //               style: AppTextStyles.bodySmall.copyWith(
      //                 color: AppColors.white,
      //               ),
      //             ),
      //             const SizedBox(height: 8),
      //             Text(
      //               selectedChild,
      //               style: AppTextStyles.bodyMedium.copyWith(
      //                 color: AppColors.white,
      //               ),
      //             ),
      //           ],
      //         ),
      //       ],
      //     ),
      //   ],
      // ),
    );
  }
}
