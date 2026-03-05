import 'dart:typed_data';

import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/core/utils/helpers.dart';
import 'package:blithepay/features/students/data/models/student_transaction_model.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/secondary_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PaymentHistoryDetailView extends StatelessWidget {
  final StudentTransactionModel transaction;

  const PaymentHistoryDetailView({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Transaction Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              transaction.status.toUpperCase(),
              style: TextStyle(
                color: transaction.status.toLowerCase() == 'success'
                    ? AppColors.success
                    : AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 32),

            _buildDetailsCard(transaction),
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: SecondaryOutlinedButton(
                    onPressed: () => _downloadReceipt(context),
                    label: 'Download Receipt',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadReceipt(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Text(
                'Transaction Receipt',
                style: pw.TextStyle(
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Divider(color: PdfColors.grey, thickness: 1.5),
              pw.SizedBox(height: 20),

              // Transaction Summary Box
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  //  borderRadius: 8,
                  color: PdfColors.grey100,
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _pdfRow('Status', transaction.status),
                    _pdfRow(
                      'Date',
                      Helpers.formatDate(transaction.transactionAt),
                    ),
                    _pdfRow('Reference', transaction.reference),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Amount Section
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  //borderRadius: BorderRadiusGeometry.all()
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _pdfRowBold('Amount', 'N${transaction.amount}'),
                    if (transaction.latePaymentFee.isNotEmpty)
                      _pdfRow(
                        'Late Payment Fees',
                        'N${transaction.latePaymentFee}',
                      ),
                    _pdfRowBold('Vat Amount', 'N${transaction.vatAmount}'),
                  ],
                ),
              ),

              pw.Spacer(),

              // Footer
              pw.Center(
                child: pw.Text(
                  'Thank you for using BilthePay',
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey700,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
    // Save PDF to device with a custom name
    final Uint8List pdfBytes = await pdf.save();

    final filename = 'blithepay_payment_recipient_${transaction.reference}.pdf';

    await Printing.sharePdf(bytes: pdfBytes, filename: filename);
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
          pw.Text(value, style: const pw.TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  pw.Widget _pdfRowBold(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

Widget _buildDetailsCard(StudentTransactionModel transaction) {
  final details = [
    {'label': 'Date', 'value': Helpers.formatDate(transaction.transactionAt)},
    {'label': 'Reference', 'value': transaction.reference},
    {'label': 'Amount', 'value': Helpers.formattedAmount(transaction.amount)},
    {
      'label': 'Late Payment Fees',
      'value': Helpers.formattedAmount(transaction.latePaymentFee),
    },
    {
      'label': 'Vat Amount',
      'value': Helpers.formattedAmount(transaction.vatAmount),
    },
    {'label': 'Description', 'value': transaction.description},
  ];

  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(8),
      color: AppColors.surface,
    ),
    child: Column(
      children: List.generate(details.length * 2 - 1, (index) {
        if (index.isOdd) {
          return const Divider(height: 1);
        }

        final item = details[index ~/ 2];

        return Padding(
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
        );
      }),
    ),
  );
}
