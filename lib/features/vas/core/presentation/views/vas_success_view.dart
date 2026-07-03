import 'package:flutter/material.dart';
import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/features/vas/core/data/models/service_purchase_response.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/background/auth_flow_background.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:blithepay/shared/widgets/buttons/secondary_outlined_button.dart';

class VasSuccessView extends StatelessWidget {
  final String title;
  final String description;
  final ServiceTransactionModel? transaction;
  final Future<void> Function(BuildContext) onDownloadReceipt;
  final VoidCallback onGoHome;

  const VasSuccessView({
    super.key,
    required this.title,
    required this.description,
    this.transaction,
    required this.onDownloadReceipt,
    required this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showBackButton: false,
      body: AuthBackgroundWrapper(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              children: [
                const Spacer(),
                
                // Success Icon
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.green.shade500,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF061657),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyRegular.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // Transaction Summary Card
                if (transaction != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F8FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE3E7F2)),
                    ),
                    child: Column(
                      children: [
                        _SummaryRow('Reference', transaction!.reference),
                        _SummaryRow(
                          'Amount',
                          '₦${transaction!.amount.toStringAsFixed(2)}',
                        ),
                        _SummaryRow(
                          'Status',
                          transaction!.status.toUpperCase(),
                          valueColor: () {
                            final upper = transaction!.status.toUpperCase();
                            if (upper == 'SUCCESS' || upper == 'SUCCESSFUL') {
                              return Colors.green.shade700;
                            } else if (upper == 'FAILED') {
                              return Colors.red.shade700;
                            } else if (upper == 'REVERSED') {
                              return Colors.orange.shade700;
                            } else {
                              return Colors.amber.shade800;
                            }
                          }(),
                        ),
                        if (transaction!.metadata != null &&
                            transaction!.metadata!.receiver.number.isNotEmpty)
                          _SummaryRow(
                            'Recipient',
                            transaction!.metadata!.receiver.number,
                          ),
                        if (transaction!.token?.isNotEmpty == true)
                          _SummaryRow('Token', transaction!.token!),
                        if (transaction!.tokenUnits?.isNotEmpty == true)
                          _SummaryRow('Units', transaction!.tokenUnits!),
                      ],
                    ),
                  ),
                ],

                const Spacer(flex: 2),

                // Actions Area wrapped in SafeArea/Padding to avoid bottom bar overlaps
                Row(
                  children: [
                    Expanded(
                      child: SecondaryOutlinedButton(
                        height: 52,
                        onPressed: () => onDownloadReceipt(context),
                        label: 'Download Receipt',
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: PrimaryButton(
                        height: 52,
                        onPressed: onGoHome,
                        label: 'Done',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: valueColor ?? const Color(0xFF061657),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
