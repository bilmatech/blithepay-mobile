import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/core/utils/helpers.dart';
import 'package:blithepay/features/fees/data/models/fee_model.dart';
import 'package:blithepay/features/students/data/models/invoice_model.dart';
import 'package:blithepay/features/students/data/repositories/students_repository.dart';
import 'package:blithepay/features/students/presentation/bloc/invoice_bloc.dart/invoice_bloc.dart';
import 'package:blithepay/features/students/presentation/bloc/invoice_bloc.dart/invoice_event.dart';
import 'package:blithepay/features/students/presentation/bloc/invoice_bloc.dart/invoice_state.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/secondary_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class InvoiceAndFeeDetailsView extends StatelessWidget {
  final InvoiceModel invoice;

  const InvoiceAndFeeDetailsView({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        title: const Text('Invoice'),
        centerTitle: true,
      ),
      body: BlocProvider(
        create: (_) =>
            InvoiceBloc(repository: context.read<StudentsRepository>())
              ..add(GetInvoiceByIdEvent(invoiceId: invoice.id)),
        child: BlocBuilder<InvoiceBloc, InvoiceState>(
          builder: (context, state) {
            if (state is InvoiceByIdLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is InvoiceByIdError) {
              return Center(child: Text(state.message));
            }

            if (state is InvoiceByIdLoaded) {
              final invoice = state.invoice;
              final fee = invoice.fee; // Fee breakdown from invoice

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 🔹 Table 1: Invoice Details
                    _buildSectionTitle('Invoice Details'),
                    const SizedBox(height: 8),
                    _buildInvoiceTable(invoice),
                    const SizedBox(height: 24),

                    // 🔹 Table 2: Fee Summary (top-level info)
                    _buildSectionTitle('Fee Details'),
                    const SizedBox(height: 8),
                    _buildFeeTable(fee),
                    const SizedBox(height: 24),

                    // 🔹 Table 3: Fee Breakdown (line items)
                    _buildSectionTitle('Fee Breakdown'),
                    const SizedBox(height: 8),
                    _buildFeeBreakdownTable(invoice.fee.feeBreakdowns ?? []),
                    const SizedBox(height: 24),

                    // Download button
                    Row(
                      children: [
                        Expanded(
                          child: SecondaryOutlinedButton(
                            onPressed: () => _downloadReceipt(context, invoice),
                            label: 'Download Invoice',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// Fee Breakdown Table
Widget _buildFeeBreakdownTable(List<FeeBreakdownModel> items) {
  final rows = items
      .map(
        (item) => {
          'label': item.name,
          'value': Helpers.formattedAmount(item.amount.toString()),
        },
      )
      .toList();

  return _buildKeyValueTable(rows);
}

Future<void> _downloadReceipt(
  BuildContext context,
  InvoiceModel invoice,
) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Invoice Receipt',
              style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),
            pw.Divider(color: PdfColors.grey, thickness: 1.5),
            pw.SizedBox(height: 20),

            // Invoice Table
            pw.Text(
              'Invoice Details',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            _pdfKeyValueTable([
              {'label': 'Invoice No', 'value': invoice.invoiceNo},
              {'label': 'Class Name', 'value': invoice.fee.classModel.name},
              {'label': 'Term Name', 'value': invoice.fee.term.name},
              {'label': 'Academic', 'value': invoice.fee.academicSession.name},
              {'label': 'Due Date', 'value': Helpers.formatDate(invoice.dueAt)},
            ]),
            pw.SizedBox(height: 24),

            // Fee Table
            pw.Text(
              'Fee Details',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            _pdfKeyValueTable([
              {'label': 'Fee Name', 'value': invoice.fee.name},
              {
                'label': 'Late Payment Fees',
                'value': 'N${invoice.fee.latePaymentFee}',
              },
            ]),
            pw.SizedBox(height: 24),

            // Fee Breakdown Table
            pw.Text(
              'Fee Breakdown',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            if (invoice.fee.feeBreakdowns != null) ...[
              _pdfKeyValueTable(
                invoice.fee.feeBreakdowns!.map((item) {
                  return {'label': item.name, 'value': 'N${item.amount}'};
                }).toList(),
              ),
            ],

            pw.Spacer(),
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

  final pdfBytes = await pdf.save();
  final filename = 'invoice_${invoice.invoiceNo}.pdf';
  await Printing.sharePdf(bytes: pdfBytes, filename: filename);
}

// class InvoiceAndFeeDetailsView extends StatelessWidget {
//   final InvoiceModel invoice;
//   final FeeModel fees;

//   const InvoiceAndFeeDetailsView({
//     super.key,
//     required this.invoice,
//     required this.fees,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return AppScaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios),
//           onPressed: () => context.pop(),
//         ),
//         title: const Text('Invoice'),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // 🔹 Table 1: Invoice Details
//             _buildSectionTitle('Invoice Details'),
//             const SizedBox(height: 8),
//             _buildInvoiceTable(invoice),
//             const SizedBox(height: 24),

//             // 🔹 Table 2: Fee Breakdown
//             _buildSectionTitle('Fee Details'),
//             const SizedBox(height: 8),
//             _buildFeeTable(fees),
//             const SizedBox(height: 24),

//             Row(
//               children: [
//                 Expanded(
//                   child: SecondaryOutlinedButton(
//                     onPressed: () => _downloadReceipt(context),
//                     label: 'Download Invoice',
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }

Widget _buildSectionTitle(String title) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Text(
      title,
      style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
    ),
  );
}

// Invoice Table
Widget _buildInvoiceTable(InvoiceModel invoice) {
  final details = [
    {'label': 'Invoice No', 'value': invoice.invoiceNo},
    {'label': 'Class Name', 'value': invoice.fee.classModel.name},
    {'label': 'Term Name', 'value': invoice.fee.term.name},
    {'label': 'Academic', 'value': invoice.fee.academicSession.name},
    {'label': 'Due Date', 'value': Helpers.formatDate(invoice.dueAt)},
  ];

  return _buildKeyValueTable(details);
}

// Fee Table
Widget _buildFeeTable(FeeModel fees) {
  final details = [
    {'label': 'Fee Name', 'value': fees.name},
    {
      'label': 'Late Payment Fees',
      'value': Helpers.formattedAmount(fees.latePaymentFee),
    },
  ];

  return _buildKeyValueTable(details);
}

// Generic Table Builder
Widget _buildKeyValueTable(List<Map<String, String>> rows) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(8),
      color: AppColors.surface,
    ),
    child: Column(
      children: List.generate(rows.length * 2 - 1, (index) {
        if (index.isOdd) return const Divider(height: 1);

        final row = rows[index ~/ 2];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                row['label']!,
                style: AppTextStyles.bodyRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  row['value']!,
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

// Future<void> _downloadReceipt(BuildContext context) async {
//   final pdf = pw.Document();

//   pdf.addPage(
//     pw.Page(
//       pageFormat: PdfPageFormat.a4,
//       margin: const pw.EdgeInsets.all(32),
//       build: (pw.Context context) {
//         return pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             // Header
//             pw.Text(
//               'Invoice Receipt',
//               style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold),
//             ),
//             pw.SizedBox(height: 12),
//             pw.Divider(color: PdfColors.grey, thickness: 1.5),
//             pw.SizedBox(height: 20),

//             // 🔹 Invoice Table
//             pw.Text(
//               'Invoice Details',
//               style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
//             ),
//             pw.SizedBox(height: 8),
//             _pdfKeyValueTable([
//               {'label': 'Invoice No', 'value': invoice.invoiceNo},
//               {'label': 'Class Name', 'value': invoice.fee.classModel.name},
//               {'label': 'Term Name', 'value': invoice.fee.term.name},
//               {'label': 'Academic', 'value': invoice.fee.academicSession.name},
//               {'label': 'Due Date', 'value': Helpers.formatDate(invoice.dueAt)},
//             ]),
//             pw.SizedBox(height: 24),

//             // 🔹 Fee Table
//             pw.Text(
//               'Fee Details',
//               style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
//             ),
//             pw.SizedBox(height: 8),
//             _pdfKeyValueTable([
//               {'label': 'Fee Name', 'value': invoice.fee.name},
//               {
//                 'label': 'Late Payment Fees',
//                 'value': 'N${invoice.fee.latePaymentFee}',
//               },
//             ]),

//             pw.Spacer(),

//             // Footer
//             pw.Center(
//               child: pw.Text(
//                 'Thank you for using BilthePay',
//                 style: pw.TextStyle(
//                   fontSize: 14,
//                   color: PdfColors.grey700,
//                   fontStyle: pw.FontStyle.italic,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     ),
//   );

//   // Save / Share PDF
//   final pdfBytes = await pdf.save();
//   final filename = 'invoice_${invoice.invoiceNo}.pdf';
//   await Printing.sharePdf(bytes: pdfBytes, filename: filename);
// }

pw.Widget _pdfKeyValueTable(List<Map<String, String>> rows) {
  return pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey300),
      borderRadius: pw.BorderRadius.circular(8),
      color: PdfColors.grey100,
    ),
    child: pw.Column(
      children: List.generate(rows.length * 2 - 1, (index) {
        if (index.isOdd) {
          return pw.Divider(height: 1, color: PdfColors.grey300);
        }

        final row = rows[index ~/ 2];
        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(row['label']!, style: const pw.TextStyle(fontSize: 12)),
              pw.Text(
                row['value']!,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }),
    ),
  );
}
