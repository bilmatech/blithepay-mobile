import 'package:blithepay/features/students/presentation/bloc/students_event.dart';
import 'package:blithepay/features/students/presentation/views/linked_student/components/empty_state.dart';
import 'package:blithepay/features/students/presentation/views/linked_student_view/linked_student_appbar.dart';
import 'package:blithepay/features/students/presentation/views/linked_student_view/linked_student_body.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/students_bloc.dart';
import '../bloc/students_state.dart';
import '../../../../shared/widgets/loaders/shimmer_list_loader.dart';

class LinkedStudentsView extends StatelessWidget {
  const LinkedStudentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const LinkedStudentsAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<StudentsBloc>().add(
            const GetLinkedStudentsEvent(refresh: true),
          );
        },
        child: BlocBuilder<StudentsBloc, StudentsState>(
          builder: (context, state) {
            if (state is StudentsLoading) {
              return const ShimmerListLoader();
            }

            if (state is StudentsLoaded) {
              if (state.students.isEmpty) {
                // Empty state MUST be scrollable
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 120),
                    buildEmptyState(context),
                  ],
                );
              }

              return LinkedStudentsBody(students: state.students);
            }

            if (state is StudentsError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 120),
                  Center(child: Text(state.message)),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
// class LinkedStudentsView extends StatefulWidget {
//   const LinkedStudentsView({super.key});

//   @override
//   State<LinkedStudentsView> createState() => _LinkedStudentsViewState();
// }

// class _LinkedStudentsViewState extends State<LinkedStudentsView> {
//   // String _searchQuery = '';
//   String? currentFilter;
//   String? currentSort;
//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController(viewportFraction: 0.95);

//     final studentsState = context.read<StudentsBloc>().state;
//     if (studentsState is! StudentsLoaded) {
//       // Only fetch if no data yet
//       context.read<StudentsBloc>().add(const GetLinkedStudentsEvent(page: 1));
//     }
//   }

//   late final PageController _pageController;
//   int _currentPage = 0;

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AppScaffold(
//       appBar: AppBar(
//         automaticallyImplyActions: false,
//         title: const Text('Linked Students'),
//         centerTitle: true,
//         actions: [
//           GestureDetector(
//             onTap: () {
//               // Handle add child action
//               context.push(AppRoutes.linkchildSchool);
//             },
//             child: const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 12),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.school_outlined, size: 22),
//                   SizedBox(height: 2),
//                   Text(
//                     'Add Child',
//                     style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),

//       body: BlocBuilder<StudentsBloc, StudentsState>(
//         builder: (context, state) {
//           if (state is StudentsLoading) {
//             return const ShimmerListLoader();
//           } else if (state is StudentsLoaded) {
//             final students = state.students;

//             if (students.isEmpty) {
//               _currentPage = 0; // reset page
//               return buildEmptyState(context);
//             }

//             // Clamp _currentPage between 0 and students.length - 1
//             _currentPage = _currentPage.clamp(0, students.length - 1);

//             final student = students[_currentPage];

//             return RefreshIndicator(
//               onRefresh: () async {
//                 context.read<StudentsBloc>().add(
//                   const GetLinkedStudentsEvent(page: 1, refresh: true),
//                 );
//               },
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children: [
//                       // Student Carousel
//                       SizedBox(
//                         height: 200,
//                         child: PageView.builder(
//                           controller: _pageController,
//                           // onPageChanged: (index) {
//                           //   setState(() => _currentPage = index);
//                           // },
//                           onPageChanged: (index) {
//                             setState(() => _currentPage = index);

//                             final students =
//                                 (context.read<StudentsBloc>().state
//                                         as StudentsLoaded)
//                                     .students;

//                             // Load next page when user scrolls to last 5 students
//                             if (index >= students.length - 5) {
//                               final nextPage = (students.length ~/ 20) + 1;
//                               context.read<StudentsBloc>().add(
//                                 GetLinkedStudentsEvent(
//                                   page: nextPage,
//                                   limit: 20,
//                                 ),
//                               );
//                             }
//                           },
//                           itemCount: students.length,
//                           itemBuilder: (context, index) {
//                             final student = students[index];
//                             return Container(
//                               margin: const EdgeInsets.only(right: 16),
//                               padding: const EdgeInsets.all(16),
//                               decoration: BoxDecoration(
//                                 color: AppColors.primary,
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       CircleAvatar(
//                                         radius: 24,
//                                         child: Text(student.fullName[0]),
//                                       ),
//                                       const SizedBox(width: 12),
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               'Student ID: ${student.regNumber}',
//                                               style: AppTextStyles.bodySmall
//                                                   .copyWith(
//                                                     color: Colors.white,
//                                                   ),
//                                             ),
//                                             Text(
//                                               student.fullName,
//                                               style: AppTextStyles.bodyLarge
//                                                   .copyWith(
//                                                     color: Colors.white,
//                                                   ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       IconButton(
//                                         icon: const Icon(
//                                           Icons.copy,
//                                           color: Colors.white,
//                                         ),
//                                         onPressed: () {},
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 12),
//                                   Row(
//                                     children: [
//                                       const Icon(
//                                         Icons.school,
//                                         color: Colors.white70,
//                                         size: 16,
//                                       ),
//                                       const SizedBox(width: 6),
//                                       Text(
//                                         student.classModel.name,
//                                         style: AppTextStyles.bodySmall.copyWith(
//                                           color: Colors.white70,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Row(
//                                     children: [
//                                       const Icon(
//                                         Icons.location_on,
//                                         color: Colors.white70,
//                                         size: 16,
//                                       ),
//                                       const SizedBox(width: 6),
//                                       Expanded(
//                                         child: Text(
//                                           student.school.name,
//                                           style: AppTextStyles.bodySmall
//                                               .copyWith(color: Colors.white70),
//                                           maxLines: 2,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const Spacer(),
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         'Fee Pending',
//                                         //  student.feeStatus,
//                                         style: AppTextStyles.bodyRegular
//                                             .copyWith(
//                                               color: AppColors.warning,
//                                               fontWeight: FontWeight.w600,
//                                             ),
//                                       ),
//                                       GestureDetector(
//                                         onTap: () => context.push('/pay-fees'),
//                                         child: Text(
//                                           'Pay Fee',
//                                           style: AppTextStyles.bodyRegular
//                                               .copyWith(color: Colors.white),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: List.generate(
//                           students.length,
//                           (index) => Container(
//                             width: 8,
//                             height: 8,
//                             margin: const EdgeInsets.symmetric(horizontal: 4),
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: index == 0
//                                   ? AppColors.primary
//                                   : AppColors.border,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 24),

//                       // Student Details
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _buildDetailBox(student.fullName),
//                           const SizedBox(height: 12),
//                           _buildDetailBox(student.classModel.name),
//                           const SizedBox(height: 12),
//                           _buildDetailBox(student.school.name),
//                           const SizedBox(height: 32),

//                           Container(
//                             width: double.infinity,
//                             padding: const EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: AppColors.lightBackground,
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'OutStanding Fees: ',
//                                   style: AppTextStyles.h4.copyWith(
//                                     color: AppColors.warning.withValues(
//                                       alpha: 0.3,
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 12),
//                                 Text(
//                                   'Amount Due: N1000',
//                                   //   'Amount Due: N${student.amountDue.toStringAsFixed(2)}',
//                                   style: AppTextStyles.bodyRegular.copyWith(
//                                     color: AppColors.textPrimary,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),

//                                 Text(
//                                   'School Uniform: N60,000',
//                                   style: AppTextStyles.bodyRegular.copyWith(
//                                     color: AppColors.textPrimary,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),

//                                 Text(
//                                   'Text Books: N100,000',
//                                   style: AppTextStyles.bodyRegular.copyWith(
//                                     color: AppColors.textPrimary,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: OutlinedButton.icon(
//                                   icon: const Icon(Icons.receipt),
//                                   style: OutlinedButton.styleFrom(
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 12,
//                                     ),
//                                     minimumSize: const Size(0, 32),
//                                     tapTargetSize:
//                                         MaterialTapTargetSize.shrinkWrap,
//                                     side: const BorderSide(
//                                       color: AppColors.border,
//                                     ),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                   ),
//                                   onPressed: () {
//                                     showDialog(
//                                       context: context,
//                                       builder: (context) => InvoiceDetailDialog(
//                                         feeType: 'Tuition Fee',
//                                         invoiceNumber: 'Invoice #34765432',
//                                         publishedDate: "21-10-25",
//                                         dueDate: '21-10-25',
//                                         totalAmount: 200000.00,
//                                         feeBreakdown: const {
//                                           'Core Tuition': 10000,
//                                           'TextBooks & Materials': 25000,
//                                           'School Uniform & ID': 35000,
//                                           'Extracirricular': 30000,
//                                         },
//                                         onPayNow: () =>
//                                             context.push(AppRoutes.addSchool),
//                                       ),
//                                     );
//                                   },
//                                   label: const Text('View Invoice'),
//                                 ),
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: OutlinedButton.icon(
//                                   style: OutlinedButton.styleFrom(
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 12,
//                                     ),
//                                     minimumSize: const Size(0, 32),
//                                     tapTargetSize:
//                                         MaterialTapTargetSize.shrinkWrap,
//                                     side: const BorderSide(
//                                       color: AppColors.border,
//                                     ),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                   ),
//                                   onPressed: () => context.push('/pay-fees'),
//                                   icon: const Icon(Icons.payment),
//                                   label: const Text('Pay Fees'),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 10),

//                           UnlinkButton(context, student),

//                           const SizedBox(height: 20),

//                           // Filter & Sort buttons
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text(
//                                 'Payment History:',
//                                 style: AppTextStyles.bodyLarge,
//                               ),
//                               GestureDetector(
//                                 onTap: () {
//                                   context.push(AppRoutes.feeTransactions);
//                                 },
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical: 6,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     border: Border.all(
//                                       color: AppColors.primary,
//                                     ),
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       Text(
//                                         'See All',
//                                         style: AppTextStyles.bodySmall.copyWith(
//                                           color: AppColors.primary,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 4),
//                                       const Icon(
//                                         Icons.arrow_forward,
//                                         color: AppColors.primary,
//                                         size: 16,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),

//                               // Row(
//                               //   children: [
//                               //     // Filter button with search
//                               //     AppOutlinedIconButton(
//                               //       onPressed: () => showFilterPopup<String>(
//                               //         context: context,
//                               //         items: [
//                               //           'Successful',
//                               //           'Failed',
//                               //           'Pending',
//                               //           'Withdrawal',
//                               //           'Fee Payment',
//                               //           'Deposit',
//                               //         ],
//                               //         selectedValue: currentFilter,
//                               //         onItemSelected: (value) =>
//                               //             setState(() => currentFilter = value),
//                               //         enableSearch: false,
//                               //       ),
//                               //       label: 'Filter',
//                               //       icon: Icons.tune,
//                               //     ),
//                               //     const SizedBox(width: 8),

//                               //     // Sort button without search
//                               //     AppOutlinedIconButton(
//                               //       onPressed: () => showFilterPopup<String>(
//                               //         context: context,
//                               //         items: [
//                               //           'A-Z',
//                               //           'Z-A',
//                               //           'Highest - Lowest',
//                               //           'Lowest - Highest',
//                               //           'Most Recent',
//                               //           'Oldest',
//                               //         ],
//                               //         selectedValue: currentSort,
//                               //         onItemSelected: (value) =>
//                               //             setState(() => currentSort = value),
//                               //         enableSearch: false, // no search for sort
//                               //       ),
//                               //       label: 'Sort by',
//                               //       icon: Icons.sort,
//                               //     ),
//                               //   ],
//                               // ),
//                             ],
//                           ),
//                           const SizedBox(height: 24),

//                           // Transaction table
//                           ListView.separated(
//                             physics: const NeverScrollableScrollPhysics(),
//                             shrinkWrap: true,
//                             itemCount: transactions.length,
//                             separatorBuilder: (_, __) =>
//                                 const SizedBox(height: 12),
//                             itemBuilder: (context, index) {
//                               final transaction = transactions[index];
//                               return TransactionContainer(
//                                 transaction: transaction,
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           }
//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }

//   Widget _buildDetailBox(String text) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       decoration: BoxDecoration(
//         border: Border.all(color: AppColors.border),
//         borderRadius: BorderRadius.circular(8),
//         color: AppColors.surface,
//       ),
//       child: Text(
//         text,
//         style: AppTextStyles.bodyRegular.copyWith(color: AppColors.textPrimary),
//       ),
//     );
//   }
// }

// final transactions = [
//   WalletTransactionModel(
//     amount: '300',
//     status: 'success',
//     id: 'cmlqkb0qr003e0vpczzqhii7l',
//     name: 'Tuition fee',
//     walletId: 'cmljgzu8w00070vp3yy5udkc8',
//     fees: '10',
//     netAmount: '198',
//     reference: '1771330263964dmgr24pmlqkayzg',
//     type: 'Deposit',
//     flow: '',
//     transactionAt: '2026-02-17T12:11:06.242Z',
//     processedAt: '2026-02-17T12:11:07.027Z',
//     isDeleted: false,
//     createdAt: '2026-02-17T12:11:07.028Z',
//     updatedAt: '2026-02-17T12:11:06.243Z',
//   ),
//   WalletTransactionModel(
//     amount: '200',
//     status: 'success',
//     id: 'cmlqkb0qr003e0vpczzqhii7l',
//     name: 'Tuition fee',
//     walletId: 'cmljgzu8w00070vp3yy5udkc8',
//     fees: '10',
//     netAmount: '',
//     reference: '1771330263964dmgr24pmlqkayzg',
//     type: 'Deposit',
//     flow: '',
//     transactionAt: '2026-02-17T12:11:06.242Z',
//     processedAt: '2026-02-17T12:11:07.027Z',
//     isDeleted: false,
//     createdAt: '2026-02-17T12:11:07.028Z',
//     updatedAt: '2026-02-17T12:11:06.243Z',
//   ),
// ];
