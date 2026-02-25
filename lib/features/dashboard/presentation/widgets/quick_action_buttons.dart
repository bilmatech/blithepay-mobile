import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class QuickActionButtons extends StatelessWidget {
  const QuickActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // _buildActionButton(
        //   backgroundColor: const Color(0xFFDEF8F1).withValues(alpha: 0.7),
        //   icon: Icons.account_balance_wallet_outlined,
        //   label: 'Fund Wallet',
        //   onTap: () {
        //     context.push(AppRoutes.fundWallet);
        //   },
        // ),
        // const SizedBox(width: 8),
        _buildActionButton(
          backgroundColor: const Color(0xFFEADDFF).withValues(alpha: 0.7),
          icon: Icons.payment_outlined,
          label: 'Pay Fees',
          onTap: () => context.push('/linked-students'),
          //            context.push(AppRoutes.payFees);
        ),
        const SizedBox(width: 8),

        _buildActionButton(
          backgroundColor: const Color(0x00ffd8e4).withValues(alpha: 0.7),
          icon: Icons.person_add_outlined,
          label: 'Link Child',
          onTap: () {
            context.push(AppRoutes.linkchildSchool);
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required Color backgroundColor,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: AppColors.primary, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
