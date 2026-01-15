import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/core/navigation/index.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:blithepay/shared/widgets/inputs/app_text_field.dart';
import 'package:blithepay/shared/widgets/inputs/dropdown_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PayFeesView extends StatefulWidget {
  const PayFeesView({super.key});

  @override
  State<PayFeesView> createState() => _PayFeesViewState();
}

class _PayFeesViewState extends State<PayFeesView> {
  // String? _selectedStudent;
  // String? _selectedFee;
  String? _selectedSchool;

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Method Section
              Text(
                'Select Payment Method:',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wallet Balance:',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          'N200,000.00',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.push(AppRoutes.fundWallet);
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Fund Wallet'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Fee Information Section
              Text(
                'Enter Student Details:',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 24),
              const AppTextField(
                label: 'Student Name',
                hint: 'Type here',
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Text(
                _selectedSchool ?? 'Select school',
                style: AppTextStyles.bodyLarge,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  showItemSelectionSheet<String>(
                    context: context,
                    title: 'Select School',
                    items: [
                      'Greenwood High',
                      'Hillview Academy',
                      'Sunrise School',
                    ],
                    selectedItem: _selectedSchool,
                    onItemSelected: (school) {
                      setState(() {
                        _selectedSchool = school;
                      });
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedSchool ?? 'Select school',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const Icon(Icons.arrow_drop_down_outlined),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const AppTextField(
                label: 'Class',
                hint: 'Type here',
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              // Due Date and Amount Info
              // Container(
              //   padding: const EdgeInsets.all(12),
              //   decoration: BoxDecoration(
              //     color: AppColors.lightBackground,
              //     borderRadius: BorderRadius.circular(8),
              //   ),
              //   child: const Column(
              //     children: [
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           Text(
              //             'Due Date:',
              //             style: TextStyle(color: AppColors.textSecondary),
              //           ),
              //           Text(
              //             '11/12/25. 09:22',
              //             style: TextStyle(fontWeight: FontWeight.w600),
              //           ),
              //         ],
              //       ),
              //       SizedBox(height: 8),
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           Text(
              //             'Amount Due:',
              //             style: TextStyle(color: AppColors.textSecondary),
              //           ),
              //           Text(
              //             'N300,000.00',
              //             style: TextStyle(
              //               fontWeight: FontWeight.w600,
              //               fontSize: 16,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
              const SizedBox(height: 40),
              PrimaryButton(
                label: 'Proceed',
                onPressed: () {
                  context.push(AppRoutes.feeSelection);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
