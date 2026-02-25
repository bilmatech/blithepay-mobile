import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:blithepay/features/fees/presentation/bloc/fees_bloc.dart';
import 'package:blithepay/features/fees/presentation/bloc/fees_state.dart';
import 'package:blithepay/features/students/data/models/invoice_model.dart';
import 'package:blithepay/features/students/data/models/verify_student_model.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class FeeBreakDownView extends StatefulWidget {
  final VerifiedStudentModel student;
  final InvoiceModel invoice;
  const FeeBreakDownView({
    super.key,
    required this.student,
    required this.invoice,
  });

  @override
  State<FeeBreakDownView> createState() => _FeeBreakDownViewState();
}

class _FeeBreakDownViewState extends State<FeeBreakDownView> {
  final Set<String> _selectedFeeIds = {};
  bool _initializedSelection = false;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Pay Fees'),
        centerTitle: true,
      ),
      body: BlocListener<FeesBloc, FeesState>(
        listener: (context, state) {
          // if (state is FeesError) {
          //   ScaffoldMessenger.of(
          //     context,
          //   ).showSnackBar(SnackBar(content: Text(state.message)));
          // }
        },
        child: BlocBuilder<FeesBloc, FeesState>(
          builder: (context, state) {
            if (state is FeesLoading || state is FeesInitial) {
              return _buildShimmer();
            }

            if (state is FeesByIdLoaded) {
              return _buildContent(context, state.fees);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // ---------------- CONTENT ----------------

  Widget _buildContent(BuildContext context, List<FeeBreakdownModel> fees) {
    // Initialize required fees ONCE after API loads
    if (!_initializedSelection) {
      _selectedFeeIds.addAll(fees.where((f) => f.isRequired).map((f) => f.id));
      _initializedSelection = true;
    }

    final optionalIds = fees
        .where((f) => !f.isRequired)
        .map((f) => f.id)
        .toSet();

    final allOptionalSelected =
        optionalIds.isEmpty || optionalIds.difference(_selectedFeeIds).isEmpty;

    final totalAmount = fees
        .where((f) => _selectedFeeIds.contains(f.id))
        .fold<int>(0, (sum, f) => sum + f.amount);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fee Breakdown:',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () => _toggleSelectAll(optionalIds),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.lightBackground,
                    ),
                    child: Row(
                      children: [
                        const Text('Select All'),
                        const SizedBox(width: 8),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                            color: allOptionalSelected
                                ? AppColors.primary
                                : Colors.white,
                          ),
                          child: allOptionalSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Fee list
            Expanded(
              child: ListView.builder(
                itemCount: fees.length,
                itemBuilder: (context, index) {
                  final fee = fees[index];
                  final isSelected = _selectedFeeIds.contains(fee.id);

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.surface,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(fee.name, style: AppTextStyles.bodyRegular),
                              if (fee.isRequired)
                                const Text(
                                  'Required',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Text('N${fee.amount.toStringAsFixed(2)}'),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: fee.isRequired
                              ? null
                              : () {
                                  setState(() {
                                    isSelected
                                        ? _selectedFeeIds.remove(fee.id)
                                        : _selectedFeeIds.add(fee.id);
                                  });
                                },
                          child: _buildSelector(
                            selected: isSelected,
                            locked: fee.isRequired,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Proceed
            PrimaryButton(
              label: 'Proceed',
              onPressed: () {
                final selectedFees = fees
                    .where((f) => _selectedFeeIds.contains(f.id))
                    .toList();

                context.push(
                  AppRoutes.feeConfirmation,
                  extra: PaymentPayload(
                    student: widget.student,
                    fees: selectedFees,
                    total: totalAmount,
                    invoice: widget.invoice,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- HELPERS ----------------

  void _toggleSelectAll(Set<String> optionalIds) {
    setState(() {
      if (optionalIds.difference(_selectedFeeIds).isEmpty) {
        _selectedFeeIds.removeAll(optionalIds);
      } else {
        _selectedFeeIds.addAll(optionalIds);
      }
    });
  }

  Widget _buildSelector({required bool selected, required bool locked}) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: locked ? AppColors.border : AppColors.primary,
        ),
      ),
      child: selected
          ? const Center(
              child: CircleAvatar(
                radius: 8,
                backgroundColor: AppColors.primary,
              ),
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
              color: AppColors.border.withOpacity(0.3),
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

  PaymentPayload({
    required this.student,
    required this.fees,
    required this.total,
    required this.invoice,
  });
}
