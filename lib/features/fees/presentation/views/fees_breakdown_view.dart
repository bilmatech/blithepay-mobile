import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:blithepay/core/utils/helpers.dart';
import 'package:blithepay/features/fees/presentation/bloc/fees_bloc.dart';
import 'package:blithepay/features/fees/presentation/bloc/fees_event.dart';
import 'package:blithepay/features/fees/presentation/bloc/fees_state.dart';
import 'package:blithepay/features/fees/presentation/bloc/payment_bloc/payment_bloc.dart';
import 'package:blithepay/features/fees/presentation/bloc/payment_bloc/payment_event.dart';
import 'package:blithepay/features/students/data/models/invoice_model.dart';
import 'package:blithepay/features/students/data/models/verify_student_model.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/arrow_button_icon.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class FeeBreakDownView extends StatefulWidget {
  final VerifiedStudentModel student;
  final String latePaymentFee;
  final InvoiceModel invoice;

  const FeeBreakDownView({
    super.key,
    required this.student,
    required this.invoice,
    required this.latePaymentFee,
  });

  @override
  State<FeeBreakDownView> createState() => _FeeBreakDownViewState();
}

class _FeeBreakDownViewState extends State<FeeBreakDownView> {
  final Set<String> _selectedFeeIds = {};
  bool _initializedSelection = false;

  @override
  void initState() {
    super.initState();

    context.read<FeesBloc>().add(
      FetchFeesByIdEvent(
        invoice: widget.invoice,
        studentCode: widget.student.school.schoolCode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        leading: const BackArrowButtonIcon(),
        title: const Text('Pay Fees'),
        centerTitle: true,
      ),
      body: BlocBuilder<FeesBloc, FeesState>(
        builder: (context, state) {
          if (state is FeesLoading) return _buildShimmer();
          if (state is FeesByIdLoaded) {
            return _buildContent(context, state.fees);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<FeeBreakdownModel> fees) {
    if (!_initializedSelection) {
      _selectedFeeIds.addAll(fees.where((f) => f.isRequired).map((f) => f.id));
      _initializedSelection = true;

      // Initialize PaymentBloc
      context.read<PaymentBloc>().add(
        InitializePayment(
          invoiceId: widget.invoice.id,
          selectedFeeIds: _selectedFeeIds,
        ),
      );
    }

    final optionalIds = fees
        .where((f) => !f.isRequired)
        .map((f) => f.id)
        .toSet();

    final totalSelectedAmount = fees
        .where((f) => f.isRequired || _selectedFeeIds.contains(f.id))
        .fold<num>(0, (sum, f) => sum + f.amount);

    final selectedCount = fees
        .where((f) => f.isRequired || _selectedFeeIds.contains(f.id))
        .length;

    final isAllOptionalSelected = optionalIds.difference(_selectedFeeIds).isEmpty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header + Select All
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fee Breakdown',
                      style: AppTextStyles.h4.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select the items you wish to pay',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (optionalIds.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isAllOptionalSelected) {
                          _selectedFeeIds.removeAll(optionalIds);
                        } else {
                          _selectedFeeIds.addAll(optionalIds);
                        }
                        context.read<PaymentBloc>().add(
                          InitializePayment(
                            invoiceId: widget.invoice.id,
                            selectedFeeIds: _selectedFeeIds,
                          ),
                        );
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isAllOptionalSelected
                            ? AppColors.primary.withValues(alpha: 0.05)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isAllOptionalSelected
                              ? AppColors.primary.withValues(alpha: 0.2)
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Select All',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isAllOptionalSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isAllOptionalSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              border: Border.all(
                                color: isAllOptionalSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: 2,
                              ),
                            ),
                            child: isAllOptionalSelected
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 12,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Fee List
            Expanded(
              child: ListView.builder(
                itemCount: fees.length,
                itemBuilder: (context, index) {
                  final fee = fees[index];
                  final isSelected =
                      fee.isRequired || _selectedFeeIds.contains(fee.id);
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected 
                            ? AppColors.primary.withValues(alpha: 0.25) 
                            : AppColors.border.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.04)
                              : Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left accent vertical bar indicator
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 5,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border.withValues(alpha: 0.5),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(14),
                                bottomLeft: Radius.circular(14),
                              ),
                            ),
                          ),
                          // Content area
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          fee.name,
                                          style: AppTextStyles.bodyLarge.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        if (fee.isRequired)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.success.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'REQUIRED',
                                              style: AppTextStyles.bodySmall.copyWith(
                                                color: AppColors.success,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 9,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          )
                                        else
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.textSecondary.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'OPTIONAL',
                                              style: AppTextStyles.bodySmall.copyWith(
                                                color: AppColors.textSecondary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 9,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    Helpers.formattedAmount(fee.amount.toString()),
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  GestureDetector(
                                    onTap: fee.isRequired
                                        ? null
                                        : () {
                                            setState(() {
                                              isSelected
                                                  ? _selectedFeeIds.remove(fee.id)
                                                  : _selectedFeeIds.add(fee.id);
                                              context.read<PaymentBloc>().add(
                                                InitializePayment(
                                                  invoiceId: widget.invoice.id,
                                                  selectedFeeIds: _selectedFeeIds,
                                                ),
                                              );
                                            });
                                          },
                                    child: _buildSelector(
                                      selected: isSelected,
                                      locked: fee.isRequired,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Total Summary Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Total',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$selectedCount of ${fees.length} items selected',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    Helpers.formattedAmount(totalSelectedAmount.toString()),
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            PrimaryButton(
              label: 'Proceed',
              onPressed: () {
                context.push(
                  AppRoutes.feeConfirmation,
                  extra: {
                    'invoiceId': widget.invoice.id,
                    'studentId': widget.student.id,
                    'feesItemIds': _selectedFeeIds,
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelector({required bool selected, required bool locked}) {
    if (locked) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: 0.1),
        ),
        child: const Icon(
          Icons.lock_rounded,
          color: AppColors.primary,
          size: 14,
        ),
      );
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.primary : Colors.transparent,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
          width: 2,
        ),
      ),
      child: selected
          ? const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 16,
            )
          : null,
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(
          5,
          (_) => Container(
            height: 60,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.border.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}

class PaymentPayload {
  final VerifiedStudentModel student;
  final List<FeeBreakdownModel> fees;
  final int total;
  final InvoiceModel invoice;
  final String latePaymentFees;

  PaymentPayload({
    required this.student,
    required this.fees,
    required this.total,
    required this.invoice,
    required this.latePaymentFees,
  });
}
