import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:blithepay/core/utils/helpers.dart';
import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/shared/widgets/buttons/secondary_outlined_button.dart';
import 'package:blithepay/shared/widgets/buttons/arrow_button_icon.dart';
import 'package:blithepay/shared/widgets/layouts/app_text.dart';
import 'package:blithepay/shared/widgets/layouts/spacing.dart';
import 'package:blithepay/features/students/data/models/student_transaction_model.dart';

class PaymentHistoryDetailView extends StatefulWidget {
  final StudentTransactionModel transaction;

  const PaymentHistoryDetailView({super.key, required this.transaction});

  @override
  State<PaymentHistoryDetailView> createState() => _PaymentHistoryDetailViewState();
}

class _PaymentHistoryDetailViewState extends State<PaymentHistoryDetailView> {
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    final upperStatus = widget.transaction.status.toUpperCase();
    final statusColor = () {
      if (upperStatus == 'SUCCESS' || upperStatus == 'SUCCESSFUL') {
        return Colors.green.shade700;
      } else if (upperStatus == 'FAILED') {
        return Colors.red.shade700;
      } else if (upperStatus == 'REVERSED') {
        return Colors.orange.shade700;
      } else {
        return Colors.amber.shade800;
      }
    }();
    final statusBg = () {
      if (upperStatus == 'SUCCESS' || upperStatus == 'SUCCESSFUL') {
        return Colors.green.shade50;
      } else if (upperStatus == 'FAILED') {
        return Colors.red.shade50;
      } else if (upperStatus == 'REVERSED') {
        return Colors.orange.shade50;
      } else {
        return Colors.amber.shade50;
      }
    }();
    final statusBorder = () {
      if (upperStatus == 'SUCCESS' || upperStatus == 'SUCCESSFUL') {
        return Colors.green.shade200;
      } else if (upperStatus == 'FAILED') {
        return Colors.red.shade200;
      } else if (upperStatus == 'REVERSED') {
        return Colors.orange.shade200;
      } else {
        return Colors.amber.shade200;
      }
    }();
    final statusDotColor = () {
      if (upperStatus == 'SUCCESS' || upperStatus == 'SUCCESSFUL') {
        return AppColors.success;
      } else if (upperStatus == 'FAILED') {
        return AppColors.error;
      } else if (upperStatus == 'REVERSED') {
        return AppColors.warning;
      } else {
        return AppColors.warning;
      }
    }();

    final displayAmount = Helpers.formattedAmount(widget.transaction.amount, flow: 'outflow').replaceAll('₦', 'N');

    return AppScaffold(
      appBar: AppBar(
        leading: const BackArrowButtonIcon(),
        title: const HeadingLg('Transaction'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeadingLg('Receipt', color: AppColors.textPrimary),
            const VSpaceBase(),
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusBorder,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusDotColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: statusDotColor.withValues(alpha: 0.4),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          upperStatus,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    displayAmount,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: statusDotColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _buildDetailsCard(widget.transaction),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: SecondaryOutlinedButton(
                    height: 44,
                    onPressed: _isDownloading ? null : () => _downloadReceipt(context),
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
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadReceipt(BuildContext context) async {
    setState(() => _isDownloading = true);
    try {
      final pdf = pw.Document();
      final tx = widget.transaction;

      // Load App Icon from assets
      final ByteData iconBytes = await rootBundle.load('assets/images/app_icon.png');
      final pw.MemoryImage appIcon = pw.MemoryImage(iconBytes.buffer.asUint8List());

      final upperStatus = tx.status.toUpperCase();
      final statusColor = () {
        if (upperStatus == 'SUCCESS' || upperStatus == 'SUCCESSFUL') {
          return PdfColors.green700;
        } else if (upperStatus == 'FAILED') {
          return PdfColors.red700;
        } else if (upperStatus == 'REVERSED') {
          return PdfColor.fromHex('#C2410C');
        } else {
          return PdfColor.fromHex('#B45309');
        }
      }();
      final dateStr = DateFormat('MMM d, yyyy HH:mm:ss').format(tx.transactionAt.toLocal());
      final cleanAmount = Helpers.formattedAmount(tx.amount).replaceAll('₦', '').trim();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                // Watermark
                pw.Opacity(
                  opacity: 0.02,
                  child: pw.Center(
                    child: pw.Image(appIcon, width: 350),
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Transaction Receipt',
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.Image(appIcon, width: 100),
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
                                style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                upperStatus,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: statusColor,
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
                                style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                'NGN $cleanAmount',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 16,
                                  color: PdfColors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 24),

                    // Section: Transaction Details
                    pw.Text(
                      'Transaction Details',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 8),

                    _pdfRow('Transaction Type', 'School Fees Payment'),
                    _pdfRow('Reference', tx.reference),
                    _pdfRow('Date & Time', dateStr),

                    // Section: Payment Details
                    pw.SizedBox(height: 16),
                    pw.Text(
                      'Payment Details',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 8),

                    _pdfRow('Student Name', '${tx.student.firstName} ${tx.student.lastName}'.trim()),
                    if (tx.invoiceId.isNotEmpty) _pdfRow('Invoice Number', tx.invoiceId),
                    if (tx.latePaymentFee.isNotEmpty && (double.tryParse(tx.latePaymentFee) ?? 0) > 0)
                      _pdfRow('Late Payment Fee', Helpers.formattedAmount(tx.latePaymentFee).replaceAll('₦', 'N')),
                    if (tx.vatAmount.isNotEmpty && (double.tryParse(tx.vatAmount) ?? 0) > 0)
                      _pdfRow('VAT Amount', Helpers.formattedAmount(tx.vatAmount).replaceAll('₦', 'N')),
                    _pdfRow('Description', tx.description),

                    pw.Spacer(),
                    pw.Divider(color: PdfColors.grey300, thickness: 0.5),
                    pw.SizedBox(height: 10),
                    pw.Center(
                      child: pw.Text(
                        'Thank you for choosing BlithePay | © ${DateTime.now().year} BlithePay. All rights reserved.',
                        style: pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey600,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
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
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
          pw.SizedBox(width: 24),
          pw.Expanded(
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                color: PdfColors.black,
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(StudentTransactionModel transaction) {
    final details = [
      {
        'label': 'Date & Time',
        'value': DateFormat('dd MMM yyyy, hh:mm a').format(transaction.transactionAt.toLocal()),
      },
      {'label': 'Reference', 'value': transaction.reference},
      {'label': 'Amount', 'value': Helpers.formattedAmount(transaction.amount).replaceAll('₦', 'N')},
      if (transaction.latePaymentFee.isNotEmpty)
        {'label': 'Late Payment Fees', 'value': Helpers.formattedAmount(transaction.latePaymentFee).replaceAll('₦', 'N')},
      if (transaction.vatAmount.isNotEmpty)
        {'label': 'Vat Amount', 'value': Helpers.formattedAmount(transaction.vatAmount).replaceAll('₦', 'N')},
      {'label': 'Description', 'value': transaction.description},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(details.length * 2 - 1, (index) {
          if (index.isOdd) {
            return Divider(
              height: 1,
              color: AppColors.border.withValues(alpha: 0.3),
              indent: 16,
              endIndent: 16,
            );
          }

          final item = details[index ~/ 2];
          final isEvenRow = (index ~/ 2).isEven;

          return Container(
            color: isEvenRow ? AppColors.lightBack.withValues(alpha: 0.02) : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['label']!,
                  style: AppTextStyles.bodyRegular.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item['value']!,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodyRegular.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
