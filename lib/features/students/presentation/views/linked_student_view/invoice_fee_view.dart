import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:blithepay/core/utils/helpers.dart';
import 'package:blithepay/features/fees/data/models/fee_selection_args.dart';
import 'package:blithepay/features/students/data/models/invoice_model.dart';
import 'package:blithepay/features/students/data/models/verify_student_model.dart';
import 'package:blithepay/features/students/data/repositories/students_repository.dart';
import 'package:blithepay/features/students/presentation/bloc/invoice_bloc.dart/invoice_bloc.dart';
import 'package:blithepay/features/students/presentation/bloc/invoice_bloc.dart/invoice_event.dart';
import 'package:blithepay/features/students/presentation/bloc/invoice_bloc.dart/invoice_state.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/layouts/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class InvoiceAndFeeDetailsView extends StatelessWidget {
  final InvoiceModel invoice;
  final VerifiedStudentModel student;

  const InvoiceAndFeeDetailsView({
    super.key,
    required this.invoice,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        title: const Text('Invoice Details'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocProvider(
          create: (_) =>
              InvoiceBloc(repository: context.read<StudentsRepository>())
                ..add(GetInvoiceByIdEvent(invoiceId: invoice.id)),
          child: BlocConsumer<InvoiceBloc, InvoiceState>(
            listener: (context, state) async {
              if (state is InvoiceDownloadState) {
                if (state.downloadStatus == InvoiceDownloadStatus.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invoice prepared successfully'),
                    ),
                  );
                } else if (state.downloadStatus ==
                        InvoiceDownloadStatus.failure &&
                    state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Download failed: ${state.errorMessage}'),
                    ),
                  );
                }
              }
            },
            builder: (context, state) {
              bool isDownloading =
                  state is InvoiceDownloadState &&
                  state.downloadStatus == InvoiceDownloadStatus.inProgress;

              // Use current invoice from state if available
              final currentInvoice = (state is InvoiceByIdLoaded)
                  ? state.invoice
                  : invoice;

              final fee = currentInvoice.fee;

              // Compute total fee amount
              final breakdownTotal = fee.feeBreakdowns?.fold<num>(
                    0,
                    (sum, item) => sum + item.amount,
                  ) ?? 0;
              final double lateFee = double.tryParse(fee.latePaymentFee) ?? 0;
              final grandTotal = breakdownTotal + lateFee;

              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Prominent Amount & Status Badge
                        Center(
                          child: Column(
                            children: [
                              Text(
                                Helpers.formattedAmount(grandTotal.toString()),
                                style: AppTextStyles.h1.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 32,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildStatusBadge(currentInvoice.status),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Digital Invoice Receipt Card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // School Info Header
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.08),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.school_rounded,
                                        color: AppColors.primary,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            student.school.name,
                                            style: AppTextStyles.bodyLarge.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'School Code: ${student.school.schoolCode}',
                                            style: AppTextStyles.bodySmall.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const DashedSeparator(),

                              // Details Metadata Grid
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    _buildMetaRow('Student Name', student.fullName),
                                    const SizedBox(height: 12),
                                    _buildMetaRow('Student Reg ID', student.regNumber),
                                    const SizedBox(height: 12),
                                    _buildMetaRow('Class / Term', '${fee.classModel.name} - ${fee.term.name}'),
                                    const SizedBox(height: 12),
                                    _buildMetaRow('Academic Session', fee.academicSession.name),
                                    const SizedBox(height: 12),
                                    _buildMetaRow('Invoice No', currentInvoice.invoiceNo),
                                    const SizedBox(height: 12),
                                    _buildMetaRow('Due Date', Helpers.formatDate(currentInvoice.dueAt)),
                                  ],
                                ),
                              ),

                              const DashedSeparator(),

                              // Fee Breakdown Header
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'FEE BREAKDOWN',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textSecondary,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    Text(
                                      'AMOUNT',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textSecondary,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Items list
                              ... (fee.feeBreakdowns ?? []).map((item) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.name,
                                        style: AppTextStyles.bodyRegular.copyWith(
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      Helpers.formattedAmount(item.amount.toString()),
                                      style: AppTextStyles.bodyRegular.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              )),

                              if (lateFee > 0)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Late Payment Fee',
                                          style: AppTextStyles.bodyRegular.copyWith(
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        Helpers.formattedAmount(fee.latePaymentFee),
                                        style: AppTextStyles.bodyRegular.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: AppOutlinedButton(
                                onPressed: isDownloading
                                    ? () {}
                                    : () {
                                        context.read<InvoiceBloc>().add(
                                          GetInvoiceByIdDownloadEvent(
                                            invoiceId: currentInvoice.id,
                                          ),
                                        );
                                      },
                                isLoading: isDownloading,
                                label: 'Download PDF',
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (currentInvoice.status != 'paid')
                              Expanded(
                                child: AppButton(
                                  onPressed: () => context.push(
                                    AppRoutes.feeSelection,
                                    extra: FeeSelectionArgs(
                                      invoice: currentInvoice,
                                      studentCode: student.school.schoolCode,
                                      student: student,
                                      latePaymentFee:
                                          currentInvoice.fee.latePaymentFee,
                                    ),
                                  ),
                                  label: 'Pay Now',
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                  // FULL-SCREEN LOADING OVERLAY
                  if (isDownloading)
                    Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      alignment: Alignment.center,
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Downloading invoice...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyRegular.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.bodyRegular.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class DashedSeparator extends StatelessWidget {
  final double height;
  final Color color;

  const DashedSeparator({
    super.key,
    this.height = 1.2,
    this.color = AppColors.border,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 6.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}
