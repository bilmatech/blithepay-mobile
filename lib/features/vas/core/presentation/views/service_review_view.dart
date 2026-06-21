import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:blithepay/features/vas/core/data/models/service_purchase_response.dart';
import 'package:blithepay/features/vas/core/presentation/views/shared/receipt_services.dart';
import 'package:blithepay/features/vas/core/presentation/views/shared/success_panel.dart';
import 'package:blithepay/features/vas/core/presentation/widgets/purchase_overlay.dart';
import 'package:blithepay/features/fees/presentation/views/widgets/pin_bottom_sheet_content.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:blithepay/shared/widgets/buttons/secondary_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:blithepay/core/network/dio_error_mapper.dart';

// ── Service Review Args ──────────────────────────────────────────────────────

class ServiceReviewDetail {
  final String label;
  final String value;
  const ServiceReviewDetail({required this.label, required this.value});
}

class ServiceReviewArgs {
  final String title;
  final int amountKobo;
  final String recipient;
  final String providerName;
  final IconData icon;
  final List<ServiceReviewDetail> summaryDetails;
  final Future<ServiceTransactionModel> Function(String pin) onPay;
  final VoidCallback onCancel;

  const ServiceReviewArgs({
    required this.title,
    required this.amountKobo,
    required this.recipient,
    required this.providerName,
    required this.icon,
    required this.summaryDetails,
    required this.onPay,
    required this.onCancel,
  });
}

// ── Helpers ───────────────────────────────────────────────────────────────────

enum PaymentMethod { wallet, card }

class PaymentMethodTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? amount;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const PaymentMethodTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.amount,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.04)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 1.8 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.border.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      amount != null ? '$subtitle: $amount' : subtitle,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                    width: 2,
                  ),
                ),
                child: selected
                    ? const Center(
                        child: CircleAvatar(
                          radius: 4,
                          backgroundColor: AppColors.white,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Main Review View ──────────────────────────────────────────────────────────

class ServiceReviewView extends StatefulWidget {
  final ServiceReviewArgs args;

  const ServiceReviewView({super.key, required this.args});

  @override
  State<ServiceReviewView> createState() => _ServiceReviewViewState();
}

class _ServiceReviewViewState extends State<ServiceReviewView> {
  PaymentMethod? _method = PaymentMethod.wallet;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final dashboardState = context.read<DashboardBloc>().state;

    return AppScaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            context.pop();
          },
        ),
        title: const Text(
          'Review Payment',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              widget.args.onCancel();
              context.go(AppRoutes.home);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 40,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── AMOUNT HERO ──────────────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 28,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                           children: [
                            const Text(
                              'TOTAL AMOUNT',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₦${(widget.args.amountKobo / 100).toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.args.title,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── ERROR BANNER ──────────────────────────────────────
                      if (_errorMessage != null && _errorMessage!.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                color: Colors.red.shade700,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red.shade900,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // ── ORDER DETAILS CARD ────────────────────────────────
                      _OrderDetailsCard(args: widget.args),

                      const SizedBox(height: 20),

                      // ── PAYMENT METHOD ────────────────────────────────────
                      const Text(
                        'Payment Method',
                        style: AppTextStyles.bodyLarge,
                      ),
                      const SizedBox(height: 12),
                      PaymentMethodTile(
                        title: 'Pay with Wallet',
                        subtitle: 'Available Balance',
                        amount: dashboardState is DashboardLoaded
                            ? dashboardState.dashboard.walletBalance
                            : null,
                        icon: Icons.account_balance_wallet_outlined,
                        selected: _method == PaymentMethod.wallet,
                        onTap: () =>
                            setState(() => _method = PaymentMethod.wallet),
                      ),
                      const SizedBox(height: 10),
                      PaymentMethodTile(
                        title: 'Pay with Card',
                        subtitle:
                            'Secure card, bank transfer, and USSD via Paystack',
                        icon: Icons.credit_card_rounded,
                        selected: _method == PaymentMethod.card,
                        onTap: () =>
                            setState(() => _method = PaymentMethod.card),
                      ),

                      const Spacer(),
                      const SizedBox(height: 28),

                      PrimaryButton(
                        label:
                            'Pay ₦${(widget.args.amountKobo / 100).toStringAsFixed(2)}',
                        onPressed: () {
                          if (_method == PaymentMethod.wallet) {
                            _showPin(context);
                          }
                        },
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showPin(BuildContext parentContext) {
    showModalBottomSheet<void>(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return PurchaseProcessingOverlay(
              visible: _isProcessing,
              child: PinBottomSheetContent(
                isLoading: _isProcessing,
                errorMessage: _errorMessage,
                onSubmit: (pin) async {
                  setModalState(() {
                    _isProcessing = true;
                    _errorMessage = null;
                  });
                  setState(() {
                    _isProcessing = true;
                    _errorMessage = null;
                  });
                  try {
                    final transaction = await widget.args.onPay(pin);
                    Navigator.pop(sheetContext);
                    _showSuccess(parentContext, transaction);
                  } catch (e) {
                    final errStr = extractError(e);
                    setModalState(() {
                      _isProcessing = false;
                      _errorMessage = errStr;
                    });
                    setState(() {
                      _isProcessing = false;
                      _errorMessage = errStr;
                    });
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccess(
    BuildContext targetContext,
    ServiceTransactionModel transaction,
  ) {
    showModalBottomSheet(
      context: targetContext,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (successContext) {
        return SuccessPanel(
          title: 'Payment Successful!',
          description:
              'Your ${widget.args.title} transaction was completed successfully.',
          transaction: transaction,
          onDownloadReceipt: () async {
            await _showReceiptPreview(successContext, transaction);
          },
          onGoHome: () {
            widget.args.onCancel();
            Navigator.pop(successContext);
            Navigator.pop(targetContext);
          },
        );
      },
    );
  }

  Future<void> _showReceiptPreview(
    BuildContext context,
    ServiceTransactionModel transaction,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => _ReceiptPreviewDialog(
        transaction: transaction,
        onDownload: () async {
          Navigator.pop(dialogCtx);
          await ReceiptService.download(transaction: transaction);
        },
      ),
    );
  }
}

// ── Service-specific Order Details ────────────────────────────────────────────

class _OrderDetailsCard extends StatelessWidget {
  final ServiceReviewArgs args;

  const _OrderDetailsCard({required this.args});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  args.icon,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Order Summary',
                style: AppTextStyles.headingSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...args.summaryDetails.map((detail) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _DetailRow(
                  label: detail.label,
                  value: detail.value,
                  isHighlight: detail.label.toLowerCase().trim() == 'amount',
                ),
              )),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyRegular.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
                fontSize: isHighlight ? 16 : 14,
                color: isHighlight ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Receipt Preview Dialog ────────────────────────────────────────────────────

class _ReceiptPreviewDialog extends StatelessWidget {
  final ServiceTransactionModel transaction;
  final VoidCallback onDownload;

  const _ReceiptPreviewDialog({
    required this.transaction,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Receipt Preview',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ref: ${transaction.reference}',
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.75),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Receipt body
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green.shade700,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          transaction.status.toUpperCase(),
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '₦${transaction.amount}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  _ReceiptRow('Reference', transaction.reference),
                  _ReceiptRow('Status', transaction.status),
                  _ReceiptRow(
                    'Amount',
                    '₦${transaction.amount.toStringAsFixed(2)}',
                  ),
                  _ReceiptRow('Date', _formatDate(transaction.createdAt)),
                  if (transaction.metadata.receiver.number.isNotEmpty)
                    _ReceiptRow(
                      'Recipient',
                      transaction.metadata.receiver.number,
                    ),
                  if (transaction.metadata.receiver.name?.isNotEmpty == true)
                    _ReceiptRow(
                      'Account Name',
                      transaction.metadata.receiver.name!,
                    ),
                  if (transaction.token?.isNotEmpty == true) ...[
                    const Divider(),
                    _ReceiptRow('Token', transaction.token!),
                    if (transaction.tokenUnits?.isNotEmpty == true)
                      _ReceiptRow('Units', transaction.tokenUnits!),
                  ],

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: SecondaryOutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          label: 'Close',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PrimaryButton(
                          label: 'Download PDF',
                          onPressed: onDownload,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}, '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReceiptRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyRegular.copyWith(
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
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
