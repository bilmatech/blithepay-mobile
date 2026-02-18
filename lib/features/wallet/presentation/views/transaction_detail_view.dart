import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/core/utils/helpers.dart';
import 'package:blithepay/features/wallet/data/models/wallet_transaction_model.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/secondary_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TransactionDetailView extends StatelessWidget {
  final WalletTransactionModel transaction;

  const TransactionDetailView({super.key, required this.transaction});

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
            const SizedBox(height: 8),

            Text(
              Helpers.formattedAmount(
                transaction.amount,
                flow: transaction.flow,
              ),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: transaction.flow.toLowerCase() == 'inflow'
                    ? AppColors.success
                    : AppColors.error,
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
                // const SizedBox(width: 12),
                // Expanded(
                //   child: ElevatedButton(
                //     onPressed: () {
                //       context.go('/home');
                //     },
                //     child: const Text('Done'),
                //   ),
                // ),
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
                    _pdfRow('Type', transaction.type),
                    _pdfRow(
                      'Date',
                      Helpers.formattedDateTime(transaction.transactionAt),
                    ),
                    _pdfRow('Reference', transaction.reference),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Amount Section
              pw.Container(
                padding: pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  //borderRadius: BorderRadiusGeometry.all()
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _pdfRowBold(
                      'Amount',
                      Helpers.formattedAmount(transaction.amount),
                    ),
                    if (transaction.fees.isNotEmpty)
                      _pdfRow(
                        'Fees',
                        Helpers.formattedAmount(transaction.fees),
                      ),
                    _pdfRowBold(
                      'Net Amount',
                      Helpers.formattedAmount(transaction.netAmount),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // Footer
              pw.Center(
                child: pw.Text(
                  'Thank you for using Our Wallet Service',
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

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
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
