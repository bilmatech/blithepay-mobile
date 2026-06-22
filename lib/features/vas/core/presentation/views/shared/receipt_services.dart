import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blithepay/core/storage/auth_local_storage.dart';
import 'package:blithepay/core/utils/helpers.dart';
import 'package:blithepay/features/vas/core/data/models/service_purchase_response.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class ReceiptService {
  static Future<void> download({
    required BuildContext context,
    required ServiceTransactionModel transaction,
  }) async {
    final pdf = pw.Document();
    final session = await context.read<AppLocalDataSource>().getSession();
    final userName = '${session?.user?.firstName ?? ''} ${session?.user?.lastName ?? ''}'.trim();

    // Load App Icon from assets
    final ByteData iconData = await rootBundle.load('assets/images/app_icon.png');
    final pw.MemoryImage appIcon = pw.MemoryImage(iconData.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (_) {
          final rawMeta = transaction.metadata.rawJson;
          final nestedMeta = rawMeta['metaData'] is Map ? rawMeta['metaData'] as Map : null;

          final discoVal = rawMeta['disco'] ?? nestedMeta?['disco'];
          final unitsVal = rawMeta['units'] ?? nestedMeta?['units'];
          final addressVal = transaction.metadata.receiver.address ??
              rawMeta['address'] ??
              nestedMeta?['address'] ??
              (rawMeta['receiver'] is Map ? rawMeta['receiver']['address'] : null);

          final parsedDate = transaction.createdAt.toLocal();
          final dateStr = DateFormat('MMM d, yyyy HH:mm:ss').format(parsedDate);
          final isSuccess = transaction.status.toLowerCase() == 'success' ||
              transaction.status.toLowerCase() == 'successful';

          final displayAmount = Helpers.formattedAmount(transaction.amount.toString()).replaceAll('₦', 'N');

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _ticketPerforation(),
              pw.SizedBox(height: 12),

              // Header Row
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Row(
                    children: [
                      pw.Image(appIcon, width: 24, height: 24),
                      pw.SizedBox(width: 8),
                      pw.Text(
                        'BlithePay',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#1E3A8A'),
                        ),
                      ),
                    ],
                  ),
                  pw.Text(
                    'Transaction Receipt',
                    style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
                  ),
                ],
              ),

              pw.SizedBox(height: 24),

              // Centered Amount & Status
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      displayAmount,
                      style: pw.TextStyle(
                        color: isSuccess ? PdfColor.fromHex('#10B981') : PdfColors.red700,
                        fontSize: 32,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: isSuccess ? PdfColor.fromHex('#EAF2FF') : PdfColors.red50,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                        border: pw.Border.all(
                          color: isSuccess ? PdfColor.fromHex('#1E3A8A') : PdfColors.red200,
                          width: 0.5,
                        ),
                      ),
                      child: pw.Text(
                        isSuccess ? 'SUCCESSFUL' : 'FAILED',
                        style: pw.TextStyle(
                          color: isSuccess ? PdfColor.fromHex('#1E3A8A') : PdfColors.red700,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      dateStr,
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 24),
              pw.Divider(color: PdfColors.grey300, thickness: 0.5),
              pw.SizedBox(height: 12),

              // Details
              if (discoVal != null || transaction.metadata.receiver.vendType != null) ...[
                // Electricity details
                _row('Provider', discoVal?.toString() ?? transaction.metadata.receiver.distribution ?? 'Utility Payment'),
                if (transaction.metadata.receiver.name?.isNotEmpty == true)
                  _row('Customer Name', transaction.metadata.receiver.name!),
                if (addressVal != null && addressVal.toString().isNotEmpty)
                  _row('Service Address', addressVal.toString()),
                if (userName.isNotEmpty)
                  _row('Till To', userName),
                _row('Purchase Type', transaction.metadata.receiver.vendType ?? 'Prepaid'),
                _row('Meter Number', transaction.metadata.receiver.number),
                if (unitsVal != null)
                  _row('Units Purchased', '${(unitsVal as num).toDouble().toStringAsFixed(1)} kWh')
                else if (transaction.tokenUnits?.isNotEmpty == true)
                  _row('Units Purchased', '${transaction.tokenUnits} kWh'),
                if (transaction.token?.isNotEmpty == true)
                  _row('Token', transaction.token!),
              ] else if (transaction.metadata.receiver.distribution?.isNotEmpty == true) ...[
                // Cable TV / Others
                _row('Provider', transaction.metadata.receiver.distribution!),
                if (transaction.metadata.receiver.name?.isNotEmpty == true)
                  _row('Customer Name', transaction.metadata.receiver.name!),
                _row('Smartcard/Account Number', transaction.metadata.receiver.number),
              ] else ...[
                // Fallback airtime/generic
                _row('Recipient Number', transaction.metadata.receiver.number),
                if (transaction.metadata.receiver.name?.isNotEmpty == true)
                  _row('Recipient Name', transaction.metadata.receiver.name!),
              ],

              _row('Hotline Number', '+234 901 740 2116'),
              _row('Transaction No.', transaction.reference),

              pw.SizedBox(height: 24),
              pw.Divider(color: PdfColors.grey300, thickness: 0.5),
              pw.SizedBox(height: 12),

              pw.Center(
                child: pw.Text(
                  'Enjoy a better life with BlithePay. Get free transfers, withdrawals, bill payments, instant loans, and good annual interest on your savings. BlithePay is licensed by the Central Bank of Nigeria and insured by the NDIC.',
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey500,
                  ),
                ),
              ),

              pw.SizedBox(height: 20),
              _ticketPerforation(),
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

  static pw.Widget _ticketPerforation() {
    return pw.Container(
      alignment: pw.Alignment.center,
      child: pw.Text(
        '•  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •',
        style: pw.TextStyle(
          color: PdfColors.grey300,
          fontSize: 10,
          letterSpacing: 2,
        ),
      ),
    );
  }

  static pw.Widget _row(String title, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 11),
          ),
          pw.SizedBox(width: 24),
          pw.Expanded(
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                color: PdfColors.black,
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
