import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blithepay/core/utils/helpers.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:blithepay/core/storage/auth_local_storage.dart';
import 'package:blithepay/features/vas/core/data/models/service_purchase_response.dart';

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
          final rawMeta = transaction.metadata?.rawJson ?? {};
          final nestedMeta = rawMeta['metaData'] is Map ? rawMeta['metaData'] as Map : null;

          final discoVal = rawMeta['disco'] ?? nestedMeta?['disco'];
          final unitsVal = rawMeta['units'] ?? nestedMeta?['units'];
          final addressVal =
              transaction.metadata?.receiver.address ??
              rawMeta['address'] ??
              nestedMeta?['address'] ??
              (rawMeta['receiver'] is Map ? rawMeta['receiver']['address'] : null);

          final parsedDate = transaction.createdAt.toLocal();
          final dateStr = DateFormat('MMM d, yyyy HH:mm:ss').format(parsedDate);
          final upperStatus = transaction.status.toUpperCase();
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

          final vendTypeUpper = transaction.metadata?.receiver.vendType?.toUpperCase() ?? '';
          final distUpper = transaction.metadata?.receiver.distribution?.toUpperCase() ?? '';
          final isAirtime = vendTypeUpper == 'AIRTIME';
          final isData = vendTypeUpper == 'DATA' || vendTypeUpper == 'INTERNET';
          final isUtility = discoVal != null ||
              vendTypeUpper == 'ELECTRICITY' ||
              vendTypeUpper == 'PREPAID' ||
              vendTypeUpper == 'POSTPAID';
          final isCable = distUpper.contains('DSTV') ||
              distUpper.contains('GOTV') ||
              distUpper.contains('STARTIMES') ||
              distUpper.contains('SHOWMAX') ||
              distUpper.contains('CABLE') ||
              distUpper.contains('TV');

          final cleanAmount = Helpers.formattedAmount(
            transaction.amount.toString(),
          ).replaceAll('₦', '').trim();

          final tokenVal = transaction.token ?? rawMeta['token'] ?? nestedMeta?['token'];

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

                  _row(
                    'Transaction Type',
                    isAirtime
                        ? 'Airtime Purchase'
                        : isData
                            ? 'Internet Data'
                            : isUtility
                                ? 'Utility Payment'
                                : isCable
                                    ? 'Cable TV Subscription'
                                    : 'Utility/Services',
                  ),
                  _row('Reference', transaction.reference),
                  _row('Date & Time', dateStr),

                  // Section: Service Details
                  if (transaction.metadata != null) ...[
                    pw.SizedBox(height: 16),
                    pw.Text(
                      'Service Details',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 8),

                    if (isAirtime) ...[
                      _row(
                        'Provider',
                        transaction.metadata!.receiver.distribution ?? 'Airtime',
                      ),
                      if (transaction.metadata!.receiver.name?.isNotEmpty == true)
                        _row('Recipient Name', transaction.metadata!.receiver.name!),
                      _row('Mobile Number', transaction.metadata!.receiver.number),
                      _row('Service Type', 'AIRTIME'),
                    ] else if (isData) ...[
                      _row(
                        'Provider',
                        transaction.metadata!.receiver.distribution ?? 'Data Bundle',
                      ),
                      if (transaction.metadata!.receiver.name?.isNotEmpty == true)
                        _row('Recipient Name', transaction.metadata!.receiver.name!),
                      _row('Mobile Number', transaction.metadata!.receiver.number),
                      _row('Service Type', 'DATA BUNDLE'),
                    ] else if (isUtility) ...[
                      _row(
                        'Provider',
                        discoVal?.toString() ??
                            transaction.metadata!.receiver.distribution ??
                            'Utility Payment',
                      ),
                      if (transaction.metadata!.receiver.name?.isNotEmpty == true)
                        _row('Customer Name', transaction.metadata!.receiver.name!),
                      if (addressVal != null && addressVal.toString().isNotEmpty)
                        _row('Service Address', addressVal.toString()),
                      if (userName.isNotEmpty) _row('Bill To', userName),
                      _row('Meter Number', transaction.metadata!.receiver.number),
                      _row('Meter Type', transaction.metadata!.receiver.vendType ?? 'Prepaid'),
                    ] else if (isCable) ...[
                      _row(
                        'Provider',
                        transaction.metadata!.receiver.distribution ?? 'Cable TV',
                      ),
                      if (transaction.metadata!.receiver.name?.isNotEmpty == true)
                        _row('Customer Name', transaction.metadata!.receiver.name!),
                      _row('Smartcard/Account Number', transaction.metadata!.receiver.number),
                      if (transaction.metadata!.receiver.vendType?.isNotEmpty == true)
                        _row('Package', transaction.metadata!.receiver.vendType!),
                    ] else ...[
                      // Fallback
                      if (transaction.metadata!.receiver.distribution?.isNotEmpty == true)
                        _row('Provider', transaction.metadata!.receiver.distribution!),
                      if (transaction.metadata!.receiver.name?.isNotEmpty == true)
                        _row('Customer Name', transaction.metadata!.receiver.name!),
                      _row('Recipient Number', transaction.metadata!.receiver.number),
                      if (transaction.metadata!.receiver.vendType?.isNotEmpty == true)
                        _row('Service Type', transaction.metadata!.receiver.vendType!),
                    ],
                  ],

                  // Token Pin Box (If available)
                  if (tokenVal != null && tokenVal.toString().isNotEmpty) ...[
                    pw.SizedBox(height: 20),
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            'PREPAID ELECTRICITY TOKEN PIN',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#1E3A8A'),
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            tokenVal.toString(),
                            style: pw.TextStyle(
                              fontSize: 22,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.black,
                              letterSpacing: 1.2,
                            ),
                          ),
                          if (unitsVal != null) ...[
                            pw.SizedBox(height: 6),
                            pw.Text(
                              'Units: ${(unitsVal as num).toDouble().toStringAsFixed(1)}',
                              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                            ),
                          ] else if (transaction.tokenUnits?.isNotEmpty == true) ...[
                            pw.SizedBox(height: 6),
                            pw.Text(
                              'Units: ${transaction.tokenUnits}',
                              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

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

    final Uint8List bytes = await pdf.save();

    await Printing.sharePdf(
      bytes: bytes,
      filename: 'blithepay_receipt_${transaction.reference}.pdf',
    );
  }

  static pw.Widget _row(String title, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
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
}
