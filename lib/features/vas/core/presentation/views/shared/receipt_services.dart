import 'dart:typed_data';
import 'package:blithepay/features/vas/core/data/models/service_purchase_response.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReceiptService {
  static Future<void> download({
    required ServiceTransactionModel transaction,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (_) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#061657'),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'BlithePay',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Transaction Receipt',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.green100,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        transaction.status.toUpperCase(),
                        style: pw.TextStyle(
                          color: PdfColors.green800,
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 24),

              // Amount section
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'TOTAL AMOUNT',
                      style: const pw.TextStyle(
                        color: PdfColors.grey600,
                        fontSize: 11,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '\u20a6${transaction.amount.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        color: PdfColor.fromHex('#061657'),
                        fontSize: 32,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 24),
              pw.Divider(),
              pw.SizedBox(height: 16),

              // Transaction details
              _row('Reference', transaction.reference),
              _row('Status', transaction.status),
              _row('Amount', '\u20a6${transaction.amount.toStringAsFixed(2)}'),
              _row('Date', _formatDate(transaction.createdAt)),

              if (transaction.metadata.receiver.number.isNotEmpty)
                _row('Recipient', transaction.metadata.receiver.number),

              if (transaction.metadata.receiver.name?.isNotEmpty == true)
                _row('Account Name', transaction.metadata.receiver.name!),

              if (transaction.token?.isNotEmpty == true) ...[
                pw.SizedBox(height: 12),
                pw.Divider(),
                pw.SizedBox(height: 8),
                pw.Text(
                  'ELECTRICITY TOKEN',
                  style: pw.TextStyle(
                    color: PdfColor.fromHex('#061657'),
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                _row('Token', transaction.token!),
                if (transaction.tokenUnits?.isNotEmpty == true)
                  _row('Units', transaction.tokenUnits!),
              ],

              if (transaction.metadata.rawJson['disco'] != null ||
                  transaction.metadata.rawJson['units'] != null) ...[
                pw.SizedBox(height: 12),
                if (transaction.metadata.rawJson['disco'] != null)
                  _row(
                    'Distribution Company',
                    transaction.metadata.rawJson['disco'].toString(),
                  ),
                if (transaction.metadata.rawJson['units'] != null)
                  _row(
                    'Units',
                    (transaction.metadata.rawJson['units'] as num)
                        .toDouble()
                        .toStringAsFixed(2),
                  ),
                if (transaction.metadata.rawJson['tax'] != null)
                  _row(
                    'Tax',
                    '₦${(transaction.metadata.rawJson['tax'] as num).toDouble().toStringAsFixed(2)}',
                  ),
              ],

              pw.SizedBox(height: 24),
              pw.Divider(),
              pw.SizedBox(height: 12),
              pw.Center(
                child: pw.Text(
                  'Thank you for using BlithePay',
                  style: const pw.TextStyle(
                    color: PdfColors.grey600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    final Uint8List bytes = await pdf.save();

    await Printing.sharePdf(
      bytes: bytes,
      filename: 'blithepay_receipt_${transaction.reference}.pdf',
    );
  }

  static String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  static pw.Widget _row(String title, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            title,
            style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 12),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              color: PdfColor.fromHex('#061657'),
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
