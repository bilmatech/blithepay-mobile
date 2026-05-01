import 'package:blithepay/core/constants/app_spacing.dart';
import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:blithepay/shared/widgets/layouts/app_text.dart';
import 'package:blithepay/shared/widgets/layouts/spacing.dart';
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
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BodyMd('TOTAL BALANCE', color: AppColors.white.withOpacity(0.7)),
              const Spacer(),
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
          const VSpaceSm(),
          DisplayMedium(
            _balanceVisible ? widget.walletBalance : '•••••••••',
            color: AppColors.white,
          ),
          const VSpaceXl(),
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.withValues(
                alpha: 0.3,
              ), // semi-transparent glass color
              borderRadius: BorderRadius.circular(24),
            ),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
              ),
              onPressed: () {
                context.push(AppRoutes.fundWallet);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Money'),
            ),
          ),
        ],
      ),
    );
  }
}
