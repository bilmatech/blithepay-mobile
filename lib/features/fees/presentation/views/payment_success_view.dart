import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/core/utils/helpers.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:blithepay/features/fees/data/models/payment_data.dart';
import 'package:blithepay/features/fees/presentation/views/fees_breakdown_view.dart';
import 'package:blithepay/features/students/presentation/bloc/invoice_bloc.dart/invoice_bloc.dart';
import 'package:blithepay/features/students/presentation/bloc/invoice_bloc.dart/invoice_event.dart';
import 'package:blithepay/features/students/presentation/views/linked_student_view/linked_student_body.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:blithepay/shared/widgets/buttons/secondary_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class PaymentSuccessView extends StatelessWidget {
  final PaymentPayload payload;
  final WalletPaymentData paymentData;

  const PaymentSuccessView({
    super.key,
    required this.payload,
    required this.paymentData,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Pay Fees'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Success Indicator
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                'Payment Successful',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '-${Helpers.formatCurrency(payload.total.toDouble())}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // Student Card
              SizedBox(
                height: 200,
                child: StudentCard(student: payload.student),
              ),
              const SizedBox(height: 24),

              // Transaction Details
              _buildDetailRow('Student', payload.student.fullName),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Total',
                Helpers.formatCurrency(payload.total.toDouble()),
              ),
              const SizedBox(height: 12),
              _buildDetailRow('Date', Helpers.formatDate(DateTime.now())),
              // const SizedBox(height: 12),
              // _buildDetailRow('Reference', payload.student.regNumber),
              const SizedBox(height: 40),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SecondaryOutlinedButton(
                      onPressed: () => _downloadReceipt(context),
                      label: 'Download Receipt',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      onPressed: () {
                        context.read<DashboardBloc>().add(
                          const FetchDashboardData(forceRefresh: true),
                        );
                        context.read<InvoiceBloc>().add(
                          GetInvoiceEvent(studentId: payload.student.id),
                        );
                        context.go('/linked-students');
                      },
                      label: 'Done',
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

  Widget _buildDetailRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.lightBackground,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _downloadReceipt(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (_) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Text(
                'Payment Receipt',
                style: pw.TextStyle(
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Divider(color: PdfColors.grey, thickness: 1.5),
              pw.SizedBox(height: 20),

              // Student & Invoice Section
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  color: PdfColors.grey100,
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _pdfRow('Student', payload.student.fullName),
                    _pdfRow('Student ID', payload.student.regNumber),
                    _pdfRow('Invoice No', paymentData.invoiceNo),
                    _pdfRow('Date', Helpers.formatDate(paymentData.paidAt)),
                    _pdfRow('Status', paymentData.status.toUpperCase()),
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
                    _pdfRowBold(
                      'Total Paid',
                      Helpers.formatCurrency(payload.total.toDouble()),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // Footer
              pw.Center(
                child: pw.Text(
                  'Thank you for using BlithePay',
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

    final filename = 'blithepay_receipt_${paymentData.invoiceNo}.pdf';

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
// class PaymentSuccessView extends StatelessWidget {
//   const PaymentSuccessView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return AppScaffold(
//       appBar: AppBar(
//         automaticallyImplyActions: false,
//         title: const Text('Pay Fees'),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               //   Success Indicator
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: const BoxDecoration(
//                   color: AppColors.success,
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(Icons.check, color: Colors.white, size: 20),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'Payment Successful',
//                 style: TextStyle(
//                   color: AppColors.success,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 '-N1,000,000',
//                 style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 32),

//               // Transaction Details
//               SizedBox(
//                 height: 200,
//                 child: StudentCardContainerWidget(
//                   margin: EdgeInsets.zero,
//                   student: StudentModel(
//                     id: '1',
//                     name: 'Adebayo Oluwaferanmi',
//                     studentId: '7ytf5675dm',
//                     class_: 'Primary 3',
//                     school: 'Seaman International Nursery & Primary School',
//                     feeStatus: 'Fee Paid',
//                     amountDue: 300000,
//                   ),
//                 ),
//               ),
//               //  _buildDetailRow('Fee:', 'Tuition Fee'),
//               const SizedBox(height: 12),
//               _buildDetailRow('Student:', 'Aishat Abdul Yusuf'),
//               // const SizedBox(height: 12),
//               //  _buildDetailRow('Method:', 'Wallet Balance'),
//               const SizedBox(height: 12),
//               _buildDetailRow('Total:', 'N1,000,000'),
//               const SizedBox(height: 12),
//               _buildDetailRow('Date:', '11/12/25. 09:22'),

//               const SizedBox(height: 12),
//               _buildDetailRow('Reference:', '98yuy6434678gfe54'),
//               const SizedBox(height: 40),

//               // Action Buttons
//               Row(
//                 children: [
//                   Expanded(
//                     child: SecondaryOutlinedButton(
//                       onPressed: () {},
//                       label: 'Download Receipt',
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         context.go('/home');
//                       },
//                       child: const Text('Done'),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         border: Border.all(color: AppColors.borderColor),
//         borderRadius: BorderRadius.circular(8),
//         color: AppColors.lightBackground,
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               color: AppColors.textSecondary,
//               fontSize: 13,
//             ),
//           ),
//           Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
//         ],
//       ),
//     );
//   }
// }
