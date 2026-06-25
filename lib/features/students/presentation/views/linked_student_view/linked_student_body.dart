import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/features/students/data/models/verify_student_model.dart';
import 'package:blithepay/features/students/presentation/bloc/invoice_bloc.dart/invoice_bloc.dart';
import 'package:blithepay/features/students/presentation/bloc/invoice_bloc.dart/invoice_event.dart';
import 'package:blithepay/features/students/presentation/views/linked_student_view/student_details_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        //  Carousel
        SizedBox(
          height: 180, // Only the top carousel
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.students.length,
            itemBuilder: (context, index) {
              final s = widget.students[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: StudentCard(data: s.toStudentCardData()),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        //  Page indicators
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

        //  Details + Outstanding Fees (scrollable)
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
  final StudentCardData data;

  const StudentCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -15,
            bottom: -15,
            child: Icon(
              Icons.school_rounded,
              size: 130,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          data.fullName.isNotEmpty ? data.fullName[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.fullName,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Student ID: ${data.regNumber}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, color: Colors.white, size: 18),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: data.regNumber));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Student ID copied to clipboard!'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: AppColors.primary,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(6),
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.class_rounded, color: Colors.white70, size: 15),
                    const SizedBox(width: 8),
                    Text(
                      data.className,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: Colors.white70, size: 15),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        data.schoolName,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension StudentCardStatusX on StudentCardStatus {
  String get label {
    switch (this) {
      case StudentCardStatus.paid:
        return 'Paid';
      case StudentCardStatus.pending:
        return 'Fee Pending';
      case StudentCardStatus.unpaid:
        return 'Unpaid';
      case StudentCardStatus.overdue:
        return 'Overdue';
      default:
        return '';
    }
  }

  Color get color {
    switch (this) {
      case StudentCardStatus.paid:
        return AppColors.success;
      case StudentCardStatus.unpaid:
        return AppColors.warning;
      case StudentCardStatus.overdue:
        return AppColors.error;
      case StudentCardStatus.pending:
        return AppColors.warning;
      default:
        return Colors.transparent;
    }
  }
}
