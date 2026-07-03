import 'package:blithepay/core/navigation/index.dart';
import 'package:blithepay/shared/widgets/buttons/arrow_button_icon.dart';
import 'package:blithepay/shared/widgets/index.dart';
import 'package:blithepay/shared/widgets/layouts/app_text.dart';
import 'package:blithepay/shared/widgets/layouts/spacing.dart';
import 'package:flutter/material.dart';
import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';

class RecurringPaymentDetailView extends StatefulWidget {
  Map<String, dynamic> recurringPayments;

  RecurringPaymentDetailView({super.key, required this.recurringPayments});

  @override
  State<RecurringPaymentDetailView> createState() =>
      _RecurringPaymentDetailViewState();
}

class _RecurringPaymentDetailViewState
    extends State<RecurringPaymentDetailView> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        leading: const BackArrowButtonIcon(),
        title: const HeadingLg('Recurring payment'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeadingLg('Details', color: AppColors.textPrimary),
            const VSpaceBase(),

            _buildDetailsCard(),

            const SizedBox(height: 32),

            PrimaryButton(
              label: 'Cancel plan',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Cancel Plan'),
                    content: const Text(
                      'Are you sure you want to cancel this recurring payment?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          context.pop();
                          setState(() {
                            // widget.recurringPayments.remove(0);
                          });
                        },
                        child: const Text('Cancel Plan'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildDetailsCard() {
  final details = [
    {'label': 'Service ', 'value': 'Electricity'},
    {'label': 'Amount', 'value': '20,000'},
    {'label': 'Method', 'value': 'Wallet Balance'},
    {'label': 'Duration', 'value': 'Weekly'},
    {'label': 'Date/timeline', 'value': '2023-10-01 10:00 AM'},
    {'label': 'Reference', 'value': 'REF-12345'},
  ];

  return Column(
    children: List.generate(details.length * 2 - 1, (index) {
      if (index.isOdd) {
        return const SizedBox();
      }

      final item = details[index ~/ 2];

      return Container(
        color: (index ~/ 2).isEven ? AppColors.surface : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item['label']!,
                style: AppTextStyles.bodyRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item['value']!,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.bodyRegular.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }),
  );
}
