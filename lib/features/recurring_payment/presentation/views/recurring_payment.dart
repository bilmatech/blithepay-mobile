import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/arrow_button_icon.dart';
import 'package:blithepay/shared/widgets/buttons/secondary_outlined_button.dart';
import 'package:blithepay/shared/widgets/layouts/app_text.dart';
import 'package:blithepay/shared/widgets/layouts/spacing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RecurringPaymentsScreen extends StatefulWidget {
  const RecurringPaymentsScreen({super.key});

  @override
  State<RecurringPaymentsScreen> createState() =>
      _RecurringPaymentsScreenState();
}

class _RecurringPaymentsScreenState extends State<RecurringPaymentsScreen> {
  final List<Map<String, dynamic>> recurringPayments = [
    {
      'id': 1,
      'service': 'Electricity',
      'amount': 20000,
      'frequency': 'Weekly',
      'date': 'Jun 17, 2024, 11:15pm',
      'icon': Icons.bolt,
      'color': const Color(0xFFFFA500),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        leading: const BackArrowButtonIcon(),
        title: const HeadingLg('Recurring Payment'),
        centerTitle: true,
      ),
      body: recurringPayments.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recurring Payment',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h4,
                      ),
                      Text(
                        'Show list of recurring & automated electricity token payment',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text('No Activity yet', style: AppTextStyles.bodyMedium),
                const VSpaceXxl(),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: recurringPayments.length,
              itemBuilder: (context, index) {
                final payment = recurringPayments[index];
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    //   context.push('/recurring-payment/${payment['id']}');
                    context.push(
                      AppRoutes.recurringPaymentDetails,
                      extra: payment,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primaryLight),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: payment['color'].withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Icon(
                                payment['icon'],
                                color: payment['color'],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    payment['service'],
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    payment['date'],
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: SecondaryOutlinedButton(
          label: '+ Add New Recurring',
          onPressed: () {
            context.push(AppRoutes.createReocurringPayment);
          },
        ),
      ),
    );
  }
}
