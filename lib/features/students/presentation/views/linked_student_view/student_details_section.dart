import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:blithepay/core/utils/helpers.dart';
import 'package:blithepay/features/fees/data/models/fee_selection_args.dart';
import 'package:blithepay/features/students/data/models/invoice_model.dart';
import 'package:blithepay/features/students/data/models/verify_student_model.dart';
import 'package:blithepay/features/students/presentation/bloc/invoice_bloc.dart/invoice_bloc.dart';
import 'package:blithepay/features/students/presentation/bloc/invoice_bloc.dart/invoice_state.dart';
import 'package:blithepay/features/students/presentation/views/linked_student/components/unlink_button.dart';
import 'package:blithepay/features/students/presentation/views/linked_student_view/payment_history_section.dart';
import 'package:blithepay/features/students/presentation/views/linked_student_view/student_info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class StudentDetailsSection extends StatelessWidget {
  final VerifiedStudentModel student;

  const StudentDetailsSection({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: StudentInfoCard(student: student),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: OutstandingFeesCard(student: student),
        ),
      ],
    );
  }
}

class OutstandingFeesCard extends StatelessWidget {
  final VerifiedStudentModel student;

  const OutstandingFeesCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InvoicesSection(student: student),
          const SizedBox(height: 16),
          UnlinkButton(context, student),
          const SizedBox(height: 20),
          PaymentHistorySection(student: student), // Pass the student here
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _InvoicesSection extends StatelessWidget {
  final VerifiedStudentModel student;
  const _InvoicesSection({required this.student});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoiceBloc, InvoiceState>(
      builder: (context, state) {
        if (state is InvoiceLoading && state.studentId == student.id) {
          return SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => Container(
                width: 160,
                decoration: BoxDecoration(
                  color: AppColors.lightBackground.withAlpha(50),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          );
        }

        if (state is InvoiceLoaded && state.studentId == student.id) {
          if (state.invoice.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text("No invoices available"),
            );
          }

          return SizedBox(
            height: 200,
            width: MediaQuery.of(context).size.width,

            child: PageView.builder(
              controller: PageController(viewportFraction: 1.0),
              itemCount: state.invoice.length,
              itemBuilder: (context, index) {
                final invoice = state.invoice[index];

                return SizedBox(
                  width: double.infinity,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //  Full Width Card
                      Expanded(child: InvoiceCard(invoice: invoice)),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.receipt, size: 16),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                side: const BorderSide(color: AppColors.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                context.push(
                                  AppRoutes.invoicedetail,
                                  extra: invoice,
                                );
                              },
                              label: const Text('View Invoice'),
                            ),
                          ),

                          // Hide Pay Fees if invoice is already paid
                          if (invoice.status.toLowerCase() != 'paid') ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.payment, size: 16),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  side: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () => context.push(
                                  AppRoutes.feeSelection,
                                  extra: FeeSelectionArgs(
                                    invoice: invoice,
                                    studentCode: student.school.schoolCode,
                                    student: student,
                                    latePaymentFee: invoice.fee.latePaymentFee,
                                  ),
                                ),
                                label: const Text('Pay Fees'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }

        return const SizedBox(
          height: 140,
          child: Center(child: Text('Invoices not loaded')),
        );
      },
    );
  }
}

class InvoiceCard extends StatelessWidget {
  final InvoiceModel invoice;
  const InvoiceCard({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Outstanding Fees',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            'Invoice No: ${invoice.invoiceNo}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            'Fee Name: ${invoice.fee.name}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          // Text(
          //   'Fee Amount: ${Helpers.formattedAmount(invoice.fee.latePaymentFee)}',
          //   style: AppTextStyles.bodySmall.copyWith(
          //     color: AppColors.textSecondary,
          //   ),
          // ),
          Text(
            'Due Date: ${Helpers.formatDate(invoice.fee.dueAt)}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Status: ${invoice.status}',
            style: AppTextStyles.bodySmall.copyWith(
              color: invoice.status.toLowerCase() == 'pending'
                  ? AppColors.warning
                  : AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
