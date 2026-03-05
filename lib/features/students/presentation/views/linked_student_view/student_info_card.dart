import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/features/students/data/models/verify_student_model.dart';
import 'package:flutter/material.dart';

class StudentInfoCard extends StatelessWidget {
  final VerifiedStudentModel student;

  const StudentInfoCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDetailBox(student.fullName),
        const SizedBox(height: 12),
        _buildDetailBox(student.classModel.name),
        const SizedBox(height: 12),
        _buildDetailBox(student.school.name),
        const SizedBox(height: 32),
      ],
    );
  }
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
