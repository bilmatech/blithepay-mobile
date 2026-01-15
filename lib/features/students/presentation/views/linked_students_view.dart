import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:blithepay/features/wallet/presentation/views/invoice_detail_dialog.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/app_outlined_icon_button.dart';
import 'package:blithepay/shared/widgets/inputs/dropdown_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/students_bloc.dart';
import '../bloc/students_event.dart';
import '../bloc/students_state.dart';
import '../../../../shared/widgets/loaders/shimmer_list_loader.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class LinkedStudentsView extends StatefulWidget {
  const LinkedStudentsView({super.key});

  @override
  State<LinkedStudentsView> createState() => _LinkedStudentsViewState();
}

class _LinkedStudentsViewState extends State<LinkedStudentsView> {
  String _searchQuery = '';
  String? currentFilter;
  String? currentSort;
  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.95);

    // Trigger students bloc to load linked students
    context.read<StudentsBloc>().add(const GetLinkedStudentsEvent());
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
          onPressed: () => context.pop(),
        ),
        title: const Text('Linked Students'),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              // Handle add child action
              context.push(AppRoutes.linkchildSchool);
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add_alt_1, size: 22),
                  SizedBox(height: 2),
                  Text(
                    'Add Child',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      body: BlocBuilder<StudentsBloc, StudentsState>(
        builder: (context, state) {
          if (state is StudentsLoading) {
            return const ShimmerListLoader();
          } else if (state is StudentsLoaded) {
            final students = state.students;
            final student = students[_currentPage];

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Student Carousel
                    SizedBox(
                      height: 200,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() => _currentPage = index);
                        },
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          return Container(
                            margin: const EdgeInsets.only(right: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      child: Text(student.name[0]),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Student ID: ${student.studentId}',
                                            style: AppTextStyles.bodySmall
                                                .copyWith(color: Colors.white),
                                          ),
                                          Text(
                                            student.name,
                                            style: AppTextStyles.bodyLarge
                                                .copyWith(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.copy,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.school,
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      student.class_,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        student.school,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: Colors.white70,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      student.feeStatus,
                                      style: AppTextStyles.bodyRegular.copyWith(
                                        color: AppColors.warning,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => context.push('/pay-fees'),
                                      child: Text(
                                        'Pay Fee',
                                        style: AppTextStyles.bodyRegular
                                            .copyWith(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        students.length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index == 0
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Student Details
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailBox(student.name),
                        const SizedBox(height: 12),
                        _buildDetailBox(student.class_),
                        const SizedBox(height: 12),
                        _buildDetailBox(student.school),
                        const SizedBox(height: 32),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.lightBackground,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'OutStanding Fees: ',
                                style: AppTextStyles.h4.copyWith(
                                  color: AppColors.warning.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Amount Due: N${student.amountDue.toStringAsFixed(2)}',
                                style: AppTextStyles.bodyRegular.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),

                              Text(
                                'School Uniform: N60,000',
                                style: AppTextStyles.bodyRegular.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),

                              Text(
                                'Text Books: N100,000',
                                style: AppTextStyles.bodyRegular.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.receipt),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  minimumSize: const Size(0, 32),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  side: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => InvoiceDetailDialog(
                                      feeType: 'Tuition Fee',
                                      invoiceNumber: 'Invoice #34765432',
                                      publishedDate: "21-10-25",
                                      dueDate: '21-10-25',
                                      totalAmount: 200000.00,
                                      feeBreakdown: const {
                                        'Core Tuition': 10000,
                                        'TextBooks & Materials': 25000,
                                        'School Uniform & ID': 35000,
                                        'Extracirricular': 30000,
                                      },
                                      onPayNow: () =>
                                          context.push(AppRoutes.addSchool),
                                    ),
                                  );
                                },
                                label: const Text('View Invoice'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  minimumSize: const Size(0, 32),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  side: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () => context.push('/pay-fees'),
                                icon: const Icon(Icons.payment),
                                label: const Text('Pay Fees'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // Filter & Sort buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Payment History:',
                              style: AppTextStyles.bodyLarge,
                            ),
                            Row(
                              children: [
                                // Filter button with search
                                AppOutlinedIconButton(
                                  onPressed: () => showFilterPopup<String>(
                                    context: context,
                                    items: [
                                      'Successful',
                                      'Failed',
                                      'Pending',
                                      'Withdrawal',
                                      'Fee Payment',
                                      'Deposit',
                                    ],
                                    selectedValue: currentFilter,
                                    onItemSelected: (value) =>
                                        setState(() => currentFilter = value),
                                    enableSearch: false,
                                  ),
                                  label: 'Filter',
                                  icon: Icons.tune,
                                ),
                                const SizedBox(width: 8),

                                // Sort button without search
                                AppOutlinedIconButton(
                                  onPressed: () => showFilterPopup<String>(
                                    context: context,
                                    items: [
                                      'A-Z',
                                      'Z-A',
                                      'Highest - Lowest',
                                      'Lowest - Highest',
                                      'Most Recent',
                                      'Oldest',
                                    ],
                                    selectedValue: currentSort,
                                    onItemSelected: (value) =>
                                        setState(() => currentSort = value),
                                    enableSearch: false, // no search for sort
                                  ),
                                  label: 'Sort by',
                                  icon: Icons.sort,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Transaction table
                        SizedBox(
                          width: double.infinity,
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.resolveWith(
                              (states) => Colors.grey.shade200,
                            ),
                            dataRowHeight: 36,
                            headingRowHeight: 36,
                            columnSpacing: 12,
                            horizontalMargin: 12,
                            columns: const [
                              DataColumn(
                                label: Text(
                                  'Date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Amount',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Method',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Type',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                            rows: transactions
                                .where(
                                  (tx) =>
                                      (tx['date']
                                              ?.toString()
                                              .toLowerCase()
                                              .contains(
                                                _searchQuery.toLowerCase(),
                                              ) ??
                                          false) ||
                                      (tx['amount']
                                              ?.toString()
                                              .toLowerCase()
                                              .contains(
                                                _searchQuery.toLowerCase(),
                                              ) ??
                                          false),
                                )
                                .map(
                                  (tx) => DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          tx['date'] ?? '',
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        onTap: () {
                                          context.push(
                                            AppRoutes.transactionDetail,
                                            extra: '12345678',
                                          );
                                          // handle cell click
                                        },
                                      ),
                                      DataCell(
                                        Text(
                                          tx['amount'] ?? '',
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        onTap: () {
                                          context.push(
                                            AppRoutes.transactionDetail,
                                            extra: '12345678',
                                          );
                                        },
                                      ),
                                      DataCell(
                                        Text(
                                          tx['method'] ?? '',
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        onTap: () {
                                          context.push(
                                            AppRoutes.transactionDetail,
                                            extra: '12345678',
                                          );
                                        },
                                      ),
                                      DataCell(
                                        Text(
                                          tx['type'] ?? '',
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        onTap: () {
                                          context.push(
                                            AppRoutes.transactionDetail,
                                            extra: '12345678',
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          } else if (state is StudentsError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDetailBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.surface,
      ),
      child: Text(
        text,
        style: AppTextStyles.bodyRegular.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}

final transactions = [
  {
    'date': '11-09-25. 11:15',
    'amount': 'N300,000.00',
    'method': 'Wallet',
    'type': 'Withdrawal',
  },
  {
    'date': '11-09-25. 11:15',
    'amount': 'N300,000.00',
    'method': 'Wallet',
    'type': 'Fee Payment',
  },
  {
    'date': '11-09-25. 11:15',
    'amount': 'N300,000.00',
    'method': 'Wallet',
    'type': 'Deposit',
  },
];
