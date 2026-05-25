import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:blithepay/core/utils/helpers.dart';
import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/shared/widgets/buttons/secondary_outlined_button.dart';
import 'package:blithepay/features/wallet/data/models/wallet_transaction_model.dart';

class WalletTransactionDetailView extends StatefulWidget {
  final WalletTransactionModel transaction;

  const WalletTransactionDetailView({super.key, required this.transaction});

  @override
  State<WalletTransactionDetailView> createState() =>
      _WalletTransactionDetailViewState();
}

class _WalletTransactionDetailViewState
    extends State<WalletTransactionDetailView> {
  bool _isDownloading = false;

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
              widget.transaction.status.toUpperCase(),
              style: TextStyle(
                color: widget.transaction.status.toLowerCase() == 'success'
                    ? AppColors.success
                    : AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              Helpers.formattedAmount(
                widget.transaction.amount,
                flow: widget.transaction.flow,
              ),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: widget.transaction.flow.toLowerCase() == 'inflow'
                    ? AppColors.success
                    : AppColors.error,
              ),
            ),

            const SizedBox(height: 32),

            _buildDetailsCard(widget.transaction),

            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: SecondaryOutlinedButton(
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
                      _pdfRow('Status', widget.transaction.status),
                      _pdfRow('Type', widget.transaction.type),
                      _pdfRow(
                        'Date',
                        Helpers.formattedDateTime(
                          widget.transaction.transactionAt,
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
                      if (widget.transaction.fees.isNotEmpty)
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

Widget _buildDetailsCard(WalletTransactionModel transaction) {
  final details = [
    {'label': 'Transaction Type', 'value': transaction.type},
    {'label': 'Method', 'value': 'Fees'},
    {
      'label': 'Date',
      'value': Helpers.formattedDateTime(transaction.transactionAt),
    },
    {'label': 'Reference', 'value': transaction.reference},
    {'label': 'Amount', 'value': Helpers.formattedAmount(transaction.amount)},
    {'label': 'Fees', 'value': Helpers.formattedAmount(transaction.fees)},
    {
      'label': 'Net Amount',
      'value': Helpers.formattedAmount(transaction.netAmount),
    },
    {'label': 'Description', 'value': transaction.description ?? '-'},
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
