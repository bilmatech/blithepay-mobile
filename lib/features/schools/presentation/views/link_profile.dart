import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/inputs/dropdown_field.dart';

class LinkProfileView extends StatefulWidget {
  const LinkProfileView({super.key});

  @override
  State<LinkProfileView> createState() => _LinkProfileViewState();
}

class _LinkProfileViewState extends State<LinkProfileView> {
  final _regNumberController = TextEditingController();
  final _admissionNumberController = TextEditingController();

  String? _selectedSchool;
  String? _registrationError;
  String? _studentError;

  @override
  void dispose() {
    _regNumberController.dispose();
    _admissionNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Link Child'), elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Student Verification',
                style: AppTextStyles.headingLarge,
              ),
              const SizedBox(height: 12),

              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://via.placeholder.com/150', // child image url
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              _buildDetailBox('Adebowale Anthony Joshua'),
              const SizedBox(height: 12),
              _buildDetailBox('s98764hgt679'),
              const SizedBox(height: 12),
              _buildDetailBox('Primary 3'),
              const SizedBox(height: 40),
              PrimaryButton(
                label: 'Link Profile',
                onPressed: () => context.push(AppRoutes.studentLinkedSuccess),
              ),
            ],
          ),
        ),
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
