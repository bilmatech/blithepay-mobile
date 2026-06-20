import 'dart:typed_data';
import 'package:blithepay/core/utils/helpers.dart';
import 'package:blithepay/features/services/data/models/service_purchase_response.dart';
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

        build: (_) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,

            children: [
              pw.Text(
                'Transaction Receipt',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 20),

              _row('Reference', transaction.reference),

              _row('Status', transaction.status),

              _row('Amount', '₦${transaction.amount}'),

              _row('Date', Helpers.formatDate(transaction.createdAt)),
            ],
          );
        },
      ),
    );

    final Uint8List bytes = await pdf.save();

    await Printing.sharePdf(
      bytes: bytes,
      filename: 'receipt_${transaction.reference}.pdf',
    );
  }

  static pw.Widget _row(String title, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),

      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,

        children: [pw.Text(title), pw.Text(value)],
      ),
    );
  }
}
