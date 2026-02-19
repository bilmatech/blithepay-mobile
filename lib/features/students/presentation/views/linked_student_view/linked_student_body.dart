import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/features/students/data/models/verify_student_model.dart';
import 'package:blithepay/features/students/presentation/bloc/invoice_bloc.dart/invoice_bloc.dart';
import 'package:blithepay/features/students/presentation/bloc/invoice_bloc.dart/invoice_event.dart';

import 'package:blithepay/features/students/presentation/views/linked_student_view/student_details_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LinkedStudentsBody extends StatefulWidget {
  final List<VerifiedStudentModel> students;
  const LinkedStudentsBody({required this.students, super.key});

  @override
  State<LinkedStudentsBody> createState() => _LinkedStudentsBodyState();
}

class _LinkedStudentsBodyState extends State<LinkedStudentsBody> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.95);

    if (widget.students.isNotEmpty) {
      final firstStudent = widget.students.first;
      context.read<InvoiceBloc>().add(
        GetInvoiceEvent(studentId: firstStudent.id),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    final student = widget.students[index];
    context.read<InvoiceBloc>().add(GetInvoiceEvent(studentId: student.id));
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.students[_currentPage];

    return Column(
      children: [
        const SizedBox(height: 12),
        // 🔹 Carousel
        SizedBox(
          height: 200, // Only the top carousel
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.students.length,
            itemBuilder: (context, index) {
              final s = widget.students[index];
              return StudentCard(student: s);
            },
          ),
        ),
        const SizedBox(height: 12),

        // 🔹 Page indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.students.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == _currentPage
                    ? AppColors.primary
                    : AppColors.border,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 🔹 Details + Outstanding Fees (scrollable)
        Expanded(
          child: SingleChildScrollView(
            child: StudentDetailsSection(student: student),
          ),
        ),
      ],
    );
  }
}

class StudentCard extends StatelessWidget {
  final VerifiedStudentModel student;

  const StudentCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              CircleAvatar(radius: 24, child: Text(student.fullName[0])),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Student ID: ${student.regNumber}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      student.fullName,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.school, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                student.classModel.name,
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  student.school.name,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fee Pending',
                //  student.feeStatus,
                style: AppTextStyles.bodyRegular.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/pay-fees'),
                child: Text(
                  'Pay Fee',
                  style: AppTextStyles.bodyRegular.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
