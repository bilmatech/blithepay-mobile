import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:blithepay/core/utils/helpers.dart';
import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/shared/widgets/buttons/arrow_button_icon.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:blithepay/shared/widgets/buttons/secondary_outlined_button.dart';
import 'package:blithepay/shared/widgets/layouts/app_text.dart';
import 'package:blithepay/shared/widgets/layouts/spacing.dart';
import 'package:blithepay/features/wallet/data/models/wallet_transaction_model.dart';
import 'package:blithepay/features/wallet/data/models/transaction_detail_response_model.dart';
import 'package:blithepay/features/wallet/data/repositories/wallet_repository.dart';

class TransactionDetailView extends StatefulWidget {
  final WalletTransactionModel transaction;

  const TransactionDetailView({super.key, required this.transaction});

  @override
  State<TransactionDetailView> createState() => _TransactionDetailViewState();
}

class _TransactionDetailViewState extends State<TransactionDetailView> {
  bool _isDownloading = false;
  Future<TransactionDetailResponseModel>? _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = context
        .read<WalletRepositoryInterface>()
        .getTransactionDetails(widget.transaction.id);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        leading: const BackArrowButtonIcon(),
        title: const HeadingLg('Transaction'),
        centerTitle: true,
      ),
      body: FutureBuilder<TransactionDetailResponseModel>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.error,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Could not load transaction details.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      snapshot.error.toString(),
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _detailsFuture = context
                              .read<WalletRepositoryInterface>()
                              .getTransactionDetails(widget.transaction.id);
                        });
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final response = snapshot.data!;
          final detail = response.data;
          final tx = detail.details;
          final vas = detail.vas;

          final isSuccess = tx.status.toLowerCase() == 'success' ||
              tx.status.toLowerCase() == 'successful';

          final isCredit = widget.transaction.flow.toLowerCase() == 'inflow';
          final displayAmount = (isCredit ? '+' : '-') +
              Helpers.formattedAmount(tx.amount.toString()).replaceAll('₦', 'N');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeadingLg('Receipt', color: AppColors.textPrimary),
                const VSpaceBase(),
                Center(
                  child: Text(
                    isSuccess ? 'Successful' : 'Failed',
                    style: TextStyle(
                      color: isSuccess ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    displayAmount,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isSuccess ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),

                // Prepaid Electricity Token Pin if available
                if (vas?.token != null && vas!.token!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'PREPAID ELECTRICITY TOKEN PIN',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          vas.token!,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            letterSpacing: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (vas.tokenUnits != null &&
                            vas.tokenUnits!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Units: ${vas.tokenUnits}',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: vas.token!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Token PIN copied to clipboard!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded, size: 16),
                          label: const Text('Copy Token'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                _buildDetailsCard(detail),

                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: SecondaryOutlinedButton(
                        height: 40,
                        onPressed: _isDownloading
                            ? null
                            : () => _downloadReceipt(context, detail),
                        label: _isDownloading ? 'Preparing...' : 'Download Receipt',
                        leading: _isDownloading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : null,
                      ),
                    ),
                    const HSpaceBase(),
                    Expanded(
                      child: PrimaryButton(
                        height: 40,
                        label: 'Repeat Transaction',
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailsCard(AppTransactionDetailData detail) {
    final tx = detail.details;
    final vas = detail.vas;

    final details = [
      {
        'label': 'Date',
        'value': DateFormat('dd/M/yyyy')
            .format(DateTime.tryParse(tx.createdAt) ?? DateTime.now()),
      },
      {'label': 'Reference', 'value': tx.reference},
      {
        'label': 'Amount',
        'value': Helpers.formattedAmount(tx.amount.toString())
      },
    ];

    if (vas != null) {
      if (vas.phone != null) {
        if (vas.phone!.contactName != null) {
          details.add(
              {'label': 'Contact Name', 'value': vas.phone!.contactName!});
        }
        details.add({'label': 'Phone Number', 'value': vas.phone!.phone});
        details.add({'label': 'Network', 'value': vas.phone!.provider});
      } else if (vas.utility != null) {
        details.add(
            {'label': 'Customer Name', 'value': vas.utility!.customerName});
        details.add(
            {'label': 'Meter Number', 'value': vas.utility!.meterNumber});
        details.add(
            {'label': 'Distributor', 'value': vas.utility!.providerName});
        details.add({'label': 'Meter Type', 'value': vas.utility!.meterType});
      } else if (vas.cabletv != null) {
        details.add(
            {'label': 'Customer Name', 'value': vas.cabletv!.customerName});
        details.add({
          'label': 'Smartcard Number',
          'value': vas.cabletv!.smartcardNumber
        });
        if (vas.cabletv!.bundleCode != null) {
          details.add(
              {'label': 'Bundle Package', 'value': vas.cabletv!.bundleCode!});
        }
      } else {
        // Fallback receiver info from metadata
        final receiver = vas.metadata?['receiver'] as Map<String, dynamic>?;
        if (receiver != null) {
          final rName = receiver['name'];
          final rNum = receiver['number'];
          final dist = receiver['distribution'];
          if (rName != null && rName.toString().isNotEmpty) {
            details.add(
                {'label': 'Recipient Name', 'value': rName.toString()});
          }
          if (rNum != null && rNum.toString().isNotEmpty) {
            details.add({'label': 'Account/Number', 'value': rNum.toString()});
          }
          if (dist != null && dist.toString().isNotEmpty) {
            details.add({'label': 'Provider', 'value': dist.toString()});
          }
        }
      }
    }

    if (tx.description.isNotEmpty) {
      details.add({'label': 'Description', 'value': tx.description});
    }

    return Column(
      children: List.generate(details.length * 2 - 1, (index) {
        if (index.isOdd) {
          return const SizedBox(height: 8);
        }

        final item = details[index ~/ 2];
        final isEvenRow = (index ~/ 2).isEven;

        return Container(
          decoration: BoxDecoration(
            color: isEvenRow
                ? AppColors.lightBack.withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['label']!,
                  style: AppTextStyles.bodyRegular.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item['value']!,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodyRegular.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> _downloadReceipt(
    BuildContext context,
    AppTransactionDetailData detail,
  ) async {
    setState(() => _isDownloading = true);
    try {
      final pdf = pw.Document();
      final tx = detail.details;
      final vas = detail.vas;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Transaction Receipt',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'BlithePay',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.indigo900,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 12),
                pw.Divider(color: PdfColors.grey400, thickness: 1),
                pw.SizedBox(height: 20),

                // Transaction Status & Amount Box
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Status',
                            style: const pw.TextStyle(
                              color: PdfColors.grey700,
                              fontSize: 10,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            tx.status,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: tx.status.toLowerCase() == 'success' ||
                                      tx.status.toLowerCase() == 'successful'
                                  ? PdfColors.green700
                                  : PdfColors.red700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'Amount',
                            style: const pw.TextStyle(
                              color: PdfColors.grey700,
                              fontSize: 10,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'NGN ${tx.amount.toString()}',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 24),

                pw.Text(
                  'Transaction Details',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                _pdfRow('Transaction Type', tx.type),
                _pdfRow('Reference', tx.reference),
                _pdfRow(
                    'Date & Time', Helpers.formattedDateTime(tx.createdAt)),

                if (vas != null) ...[
                  pw.SizedBox(height: 12),
                  pw.Text(
                    'Service Details',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  if (vas.phone != null) ...[
                    if (vas.phone!.contactName != null)
                      _pdfRow('Contact Name', vas.phone!.contactName!),
                    _pdfRow('Phone Number', vas.phone!.phone),
                    _pdfRow('Network', vas.phone!.provider),
                  ] else if (vas.utility != null) ...[
                    _pdfRow('Customer Name', vas.utility!.customerName),
                    _pdfRow('Meter Number', vas.utility!.meterNumber),
                    _pdfRow('Distributor', vas.utility!.providerName),
                    _pdfRow('Meter Type', vas.utility!.meterType),
                  ] else if (vas.cabletv != null) ...[
                    _pdfRow('Customer Name', vas.cabletv!.customerName),
                    _pdfRow('Smartcard Number', vas.cabletv!.smartcardNumber),
                    if (vas.cabletv!.bundleCode != null)
                      _pdfRow('Bundle Package', vas.cabletv!.bundleCode!),
                  ] else ...[
                    if (vas.metadata != null &&
                        vas.metadata!['receiver'] != null) ...[
                      if (vas.metadata!['receiver']['name'] != null)
                        _pdfRow(
                          'Receiver Name',
                          vas.metadata!['receiver']['name'].toString(),
                        ),
                      if (vas.metadata!['receiver']['number'] != null)
                        _pdfRow(
                          'Receiver Account/Number',
                          vas.metadata!['receiver']['number'].toString(),
                        ),
                      if (vas.metadata!['receiver']['distribution'] != null)
                        _pdfRow(
                          'Provider',
                          vas.metadata!['receiver']['distribution']
                              .toString(),
                        ),
                    ],
                  ],
                ],

                if (vas?.token != null && vas!.token!.isNotEmpty) ...[
                  pw.SizedBox(height: 20),
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400),
                      borderRadius:
                          const pw.BorderRadius.all(pw.Radius.circular(6)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'PREPAID ELECTRICITY TOKEN PIN',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.indigo900,
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          vas.token!,
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        if (vas.tokenUnits != null &&
                            vas.tokenUnits!.isNotEmpty) ...[
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Units: ${vas.tokenUnits}',
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                pw.Spacer(),
                pw.Divider(color: PdfColors.grey300),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text(
                    'Thank you for choosing BlithePay',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );

      final Uint8List pdfBytes = await pdf.save();
      final filename = 'blithepay_receipt_${tx.reference}.pdf';
      await Printing.sharePdf(bytes: pdfBytes, filename: filename);
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }
}