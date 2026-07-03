import 'dart:io';
import 'dart:ui';

import 'package:blithepay/core/utils/helpers.dart';
import 'package:blithepay/features/wallet/data/models/wallet_transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class TransactionReceiptView extends StatefulWidget {
  final WalletTransactionModel transaction;

  const TransactionReceiptView({super.key, required this.transaction});

  @override
  State<TransactionReceiptView> createState() => _TransactionReceiptViewState();
}

class _TransactionReceiptViewState extends State<TransactionReceiptView> {
  final GlobalKey _receiptKey = GlobalKey();

  Future<void> _saveAsPNG() async {
    try {
      final boundary =
          _receiptKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final dir = await getApplicationDocumentsDirectory();
      final file = File(
        '${dir.path}/Receipt_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('PNG saved successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving PNG: $e')));
    }
  }

  Future<void> _saveAsPDF() async {
    try {
      final pdf = pw.Document();
      final boundary =
          _receiptKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final pdfImage = pw.MemoryImage(bytes);

      pdf.addPage(
        pw.Page(build: (context) => pw.Center(child: pw.Image(pdfImage))),
      );

      final dir = await getApplicationDocumentsDirectory();
      final file = File(
        '${dir.path}/Receipt_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('PDF saved successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving PDF: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Receipt')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              RepaintBoundary(
                key: _receiptKey,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Transaction Receipt',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[900],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _receiptRow('Status', widget.transaction.status),
                      _receiptRow(
                        'Amount',
                        Helpers.formattedAmount(widget.transaction.amount),
                      ),
                      _receiptRow('Type', widget.transaction.type),
                      _receiptRow(
                        'Date',
                        Helpers.formattedDateTime(
                          widget.transaction.transactionAt,
                        ),
                      ),
                      _receiptRow('Reference', widget.transaction.reference),
                      _receiptRow(
                        'Fees',
                        Helpers.formattedAmount(widget.transaction.fees),
                      ),
                      _receiptRow(
                        'Net Amount',
                        Helpers.formattedAmount(widget.transaction.netAmount),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveAsPNG,
                      icon: const Icon(Icons.image),
                      label: const Text('Save as PNG'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveAsPDF,
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Save as PDF'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
