import 'package:blithepay/core/constants/app_spacing.dart';
import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:blithepay/shared/widgets/layouts/app_text.dart';
import 'package:blithepay/shared/widgets/layouts/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:blithepay/core/storage/auth_local_storage.dart';

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
  bool _balanceVisible = false;

  @override
  void initState() {
    super.initState();
    _loadBalanceVisibility();
  }

  Future<void> _loadBalanceVisibility() async {
    try {
      final visible = await context.read<AppLocalDataSource>().isBalanceVisible();
      if (mounted) {
        setState(() {
          _balanceVisible = visible;
        });
      }
    } catch (e) {
      debugPrint('Failed to load balance visibility: $e');
    }
  }

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
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BodyMd(
                'TOTAL BALANCE',
                color: AppColors.white.withValues(alpha: 0.7),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  _balanceVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () async {
                  final newValue = !_balanceVisible;
                  setState(() {
                    _balanceVisible = newValue;
                  });
                  try {
                    await context.read<AppLocalDataSource>().setBalanceVisible(newValue);
                  } catch (e) {
                    debugPrint('Failed to save balance visibility: $e');
                  }
                },
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
