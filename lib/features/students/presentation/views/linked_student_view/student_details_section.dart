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
import 'package:blithepay/shared/widgets/layouts/app_button.dart';
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
                  color: AppColors.lightBackground.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          );
        }

        List<InvoiceModel> invoices = [];

        if (state is InvoiceLoaded && state.studentId == student.id) {
          invoices = state.invoice;
        } else if (state is InvoiceByIdLoading &&
            state.existingInvoices != null) {
          invoices = state.existingInvoices!;
        } else if (state is InvoiceByIdViewLoaded &&
            state.existingInvoices != null) {
          invoices = state.existingInvoices!;
        }

        if (invoices.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text("No invoices available"),
          );
        }

        return SizedBox(
          height: 220,
          width: MediaQuery.of(context).size.width,

          child: PageView.builder(
            controller: PageController(viewportFraction: 1.0),
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];

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
                          child: AppOutlinedButton(
                            height: 40,
                            borderRadius: 8,
                            onPressed: () {
                              context.push(
                                AppRoutes.invoicedetail,
                                extra: {'invoice': invoice, 'student': student},
                              );
                            },
                            label: 'View Invoice',
                          ),
                        ),

                        // Hide Pay Fees if invoice is already paid
                        if (invoice.status.toLowerCase() != 'paid') ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppButton(
                              height: 40,
                              borderRadius: 8,
                              onPressed: () => context.push(
                                AppRoutes.feeSelection,
                                extra: FeeSelectionArgs(
                                  invoice: invoice,
                                  studentCode: student.school.schoolCode,
                                  student: student,
                                  latePaymentFee: invoice.fee.latePaymentFee,
                                ),
                              ),
                              label: 'Pay Fees',
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
      },
    );
  }
}

class InvoiceCard extends StatelessWidget {
  final InvoiceModel invoice;
  const InvoiceCard({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    // Compute grand total
    final totalAmount = invoice.fee.feeBreakdowns?.fold<num>(
          0,
          (sum, item) => sum + item.amount,
        ) ?? 0;
    final double lateFee = double.tryParse(invoice.fee.latePaymentFee) ?? 0;
    final grandTotal = totalAmount + lateFee;

    final isPaid = invoice.status.toLowerCase() == 'paid';
    final isPending = invoice.status.toLowerCase() == 'pending';
    final accentColor = isPaid 
        ? AppColors.success 
        : (isPending ? AppColors.warning : AppColors.error);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            invoice.fee.name,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(invoice.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          Helpers.formattedAmount(grandTotal.toString()),
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                          ),
                        ),
                        Text(
                          'Inv No: ${invoice.invoiceNo}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textTertiary),
                        const SizedBox(width: 6),
                        Text(
                          'Due Date: ${Helpers.formatDate(invoice.dueAt)}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final s = status.toLowerCase();
    Color bgColor = AppColors.warning.withValues(alpha: 0.1);
    Color textColor = AppColors.warning;

    if (s == 'paid') {
      bgColor = AppColors.success.withValues(alpha: 0.1);
      textColor = AppColors.success;
    } else if (s == 'overdue' || s == 'failed') {
      bgColor = AppColors.error.withValues(alpha: 0.1);
      textColor = AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 9,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
