import 'dart:typed_data';
import 'package:blithepay/features/transaction/data/model/transaction_model.dart';
import 'package:blithepay/shared/widgets/buttons/arrow_button_icon.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:blithepay/shared/widgets/layouts/app_text.dart';
import 'package:blithepay/shared/widgets/layouts/spacing.dart';
import 'package:pdf/pdf.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:blithepay/core/utils/helpers.dart';
import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/shared/widgets/buttons/secondary_outlined_button.dart';

class TransactionDetailView extends StatefulWidget {
  final TransactionModel transaction;

  const TransactionDetailView({super.key, required this.transaction});

  @override
  State<TransactionDetailView> createState() => _TransactionDetailViewState();
}

class _TransactionDetailViewState extends State<TransactionDetailView> {
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        leading: const BackArrowButtonIcon(),
        title: const HeadingLg('Transaction'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeadingLg('Receipt', color: AppColors.textPrimary),
            const VSpaceBase(),
            Center(
              child: Text(
                widget.transaction.status.name,
                style: TextStyle(
                  color:
                      widget.transaction.status.name.toLowerCase() ==
                          'successful'
                      ? AppColors.success
                      : AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                widget.transaction.amount,              
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      widget.transaction.status.name.toLowerCase() ==
                          'successful'
                      ? AppColors.success
                      : AppColors.error,
                ),
              ),
            ),

            const SizedBox(height: 32),

            _buildDetailsCard(widget.transaction),

            const SizedBox(height: 32),

            Row(
              children: [
                SecondaryOutlinedButton(
                  height: 40,
                  onPressed: _isDownloading
                      ? null
                      : () => _downloadReceipt(context),
                  label: _isDownloading ? 'Preparing...' : 'Download Receipt',
                  leading: _isDownloading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
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
      ),
    );
  }

  Future<void> _downloadReceipt(BuildContext context) async {
    setState(() => _isDownloading = true);
    try {
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
                    color: PdfColors.grey100,
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _pdfRow('Status', widget.transaction.status.name),
                      _pdfRow('Type', widget.transaction.type.name),
                      _pdfRow(
                        'Date',
                        Helpers.formattedDateTime(
                          widget.transaction.transactionAt.toString(),
                        ),
                      ),
                      _pdfRow('Reference', widget.transaction.reference),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Amount Section
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _pdfRowBold('Amount', 'N${widget.transaction.amount}'),
                      if (widget.transaction.fees.toString().isNotEmpty)
                        _pdfRow('Fees', 'N${widget.transaction.fees}'),
                      _pdfRowBold(
                        'Net Amount',
                        'N${widget.transaction.netAmount}',
                      ),
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

      final Uint8List pdfBytes = await pdf.save();
      final filename =
          'blithepay_transaction_recipient_${widget.transaction.reference}.pdf';
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

Widget _buildDetailsCard(TransactionModel transaction) {
  final details = [
    {'label': 'Transaction Type', 'value': transaction.type.name},
    {'label': 'Method', 'value': 'Fees'},
    {
      'label': 'Date',
      'value': Helpers.formattedDateTime(transaction.transactionAt.toString()),
    },
    {'label': 'Reference', 'value': transaction.reference},
    {'label': 'Amount', 'value': Helpers.formattedAmount(transaction.amount)},
    {
      'label': 'Fees',
      'value': Helpers.formattedAmount(transaction.fees.toString()),
    },
    {
      'label': 'Net Amount',
      'value': Helpers.formattedAmount(transaction.netAmount),
    },
    {'label': 'Description', 'value': transaction.desc.toString()},
  ];

  return Column(
    children: List.generate(details.length * 2 - 1, (index) {
      if (index.isOdd) {
        return const SizedBox();
      }

      final item = details[index ~/ 2];

      return Container(
        color: (index ~/ 2).isEven ? AppColors.surface : Colors.transparent,
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