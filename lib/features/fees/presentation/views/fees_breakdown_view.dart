import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FeeBreakDownView extends StatefulWidget {
  final List<Map<String, dynamic>> fees;

  const FeeBreakDownView({super.key, required this.fees});

  @override
  State<FeeBreakDownView> createState() => _FeeBreakDownViewState();
}

class _FeeBreakDownViewState extends State<FeeBreakDownView> {
  final Set<String> _selectedFees = {};
  bool _selectAll = false;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pay Fees'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header: Fee Breakdown + Select All
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fee Breakdown:',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
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
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectAll = !_selectAll;
                              _selectedFees.clear();
                              if (_selectAll) {
                                _selectedFees.addAll(
                                  widget.fees.map((f) => f['name'] as String),
                                );
                              }
                            });
                          },
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2,
                              ),
                              color: _selectAll
                                  ? AppColors.primary
                                  : Colors.white,
                            ),
                            child: _selectAll
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Fee items
              Expanded(
                child: ListView.builder(
                  itemCount: widget.fees.length,
                  itemBuilder: (context, index) {
                    final fee = widget.fees[index];
                    final feeName = fee['name'] as String;
                    final feeAmount = fee['amount'] as num;
                    final isSelected = _selectedFees.contains(feeName);

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.surface,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              feeName,
                              style: AppTextStyles.bodyRegular.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            'N${feeAmount.toStringAsFixed(2)}',
                            style: AppTextStyles.bodyRegular.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Big radio-style selector
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedFees.remove(feeName);
                                } else {
                                  _selectedFees.add(feeName);
                                }

                                // Update selectAll
                                _selectAll =
                                    _selectedFees.length == widget.fees.length;
                              });
                            },
                            child: Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 1,
                                ),
                                color: Colors
                                    .white, // always white background for outer circle
                              ),
                              child: isSelected
                                  ? Container(
                                      width: 20,
                                      height: 20,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors
                                            .primary, // inner filled circle
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Pay Now Button
              PrimaryButton(
                label: 'Proceed',
                onPressed: () {
                  // Here you can pass _selectedFees to your payment logic
                  print('Selected Fees: $_selectedFees');
                  context.push(AppRoutes.feeConfirmation);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
