import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/features/vas/core/data/models/service_purchase_response.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:blithepay/shared/widgets/buttons/secondary_outlined_button.dart';
import 'package:flutter/material.dart';

class SuccessPanel extends StatelessWidget {
  final String title;
  final String description;
  final ServiceTransactionModel? transaction;
  final Future<void> Function() onDownloadReceipt;
  final VoidCallback onGoHome;

  const SuccessPanel({
    super.key,
    required this.title,
    required this.description,
    this.transaction,
    required this.onDownloadReceipt,
    required this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 36),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Drag handle ──────────────────────────────────────────
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // ── Success icon ──────────────────────────────────────────
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.green.shade500,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF061657),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyRegular.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                // ── Transaction summary snippet ────────────────────────────
                if (transaction != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F8FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE3E7F2)),
                    ),
                    child: Column(
                      children: [
                        _SummaryRow(
                          'Reference',
                          transaction!.reference,
                        ),
                        _SummaryRow(
                          'Amount',
                          '₦${transaction!.amount.toStringAsFixed(2)}',
                        ),
                        _SummaryRow('Status', transaction!.status),
                        if (transaction!.metadata.receiver.number.isNotEmpty)
                          _SummaryRow(
                            'Recipient',
                            transaction!.metadata.receiver.number,
                          ),
                        if (transaction!.token?.isNotEmpty == true)
                          _SummaryRow('Token', transaction!.token!),
                        if (transaction!.tokenUnits?.isNotEmpty == true)
                          _SummaryRow('Units', transaction!.tokenUnits!),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                Row(
                  children: [
                    Expanded(
                      child: SecondaryOutlinedButton(
                        height: 52,
                        onPressed: onDownloadReceipt,
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
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
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
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Color(0xFF061657),
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
