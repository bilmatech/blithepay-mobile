import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/navigation/index.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:blithepay/features/fees/presentation/views/widgets/student_card_container_widget.dart';
import 'package:blithepay/features/students/data/models/student_model.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:flutter/material.dart';

class PayFeesView extends StatefulWidget {
  const PayFeesView({super.key});

  @override
  State<PayFeesView> createState() => _PayFeesViewState();
}

class _PayFeesViewState extends State<PayFeesView> {
  // String? _selectedStudent;
  // String? _selectedFee;
  // String? _selectedSchool;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.95);
  }

  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Wallet Balance:',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        BlocBuilder<DashboardBloc, DashboardState>(
                          builder: (context, state) {
                            if (state is DashboardLoaded) {
                              return Text(
                                state.dashboard.walletBalance,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }

                            return const Text(
                              '--',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
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

              SizedBox(
                height: 200,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final isSelected = _selectedIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 4),
                        padding: EdgeInsets.all(
                          isSelected ? 5 : 0,
                        ), // outward animation
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.warning
                                : Colors.transparent,
                            width: 2, // fixed width
                          ),
                        ),
                        child: StudentCardContainerWidget(
                          margin: EdgeInsets.zero,
                          student: student,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Fee Information Section
              // Text(
              //   'Enter Student Details:',
              //   style: Theme.of(context).textTheme.labelLarge,
              // ),
              // const SizedBox(height: 24),
              // const AppTextField(
              //   label: 'Student Name',
              //   hint: 'Type here',
              //   maxLines: 3,
              // ),
              // const SizedBox(height: 24),
              // Text(
              //   _selectedSchool ?? 'Select school',
              //   style: AppTextStyles.bodyLarge,
              // ),
              // const SizedBox(height: 8),
              // GestureDetector(
              //   onTap: () {
              //     showItemSelectionSheet<String>(
              //       context: context,
              //       title: 'Select School',
              //       items: [
              //         'Greenwood High',
              //         'Hillview Academy',
              //         'Sunrise School',
              //       ],
              //       selectedItem: _selectedSchool,
              //       onItemSelected: (school) {
              //         setState(() {
              //           _selectedSchool = school;
              //         });
              //       },
              //     );
              //   },
              //   child: Container(
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 16,
              //       vertical: 14,
              //     ),
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(12),
              //       border: Border.all(color: Colors.grey.shade300),
              //     ),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Text(
              //           _selectedSchool ?? 'Select school',
              //           style: const TextStyle(fontSize: 14),
              //         ),
              //         const Icon(Icons.arrow_drop_down_outlined),
              //       ],
              //     ),
              //   ),
              // ),

              // const SizedBox(height: 24),

              // const AppTextField(
              //   label: 'Class',
              //   hint: 'Type here',
              //   maxLines: 3,
              // ),
              // const SizedBox(height: 12),

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

              // PrimaryButton(
              //   label: 'Proceed',
              //   isEnabled: _selectedIndex != null,
              //   onPressed: _selectedIndex == null
              //       ? () {}
              //       : () {
              //           final selectedStudent = students[_selectedIndex!];
              //           context.push(
              //             AppRoutes.feeSelection,
              //             extra: FeeSelectionArgs(
              //               feeId: '',
              //               studentCode: '',
              //               student: selectedStudent,
              //             ),
              //           );
              //         },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

var students = [
  StudentModel(
    id: '1',
    name: 'Adebayo Oluwaferanmi',
    studentId: '7ytf5675dm',
    class_: 'Primary 3',
    school: 'Seaman International Nursery & Primary School',
    feeStatus: 'Fee Pending',
    amountDue: 300000,
  ),
  StudentModel(
    id: '2',
    name: 'Emma Oluwatayo',
    studentId: '7ytf3475dm',
    class_: 'Primary 4',
    school: 'Seaman International Nursery & Primary School',
    feeStatus: 'Fee Pending',
    amountDue: 100000,
  ),
];
