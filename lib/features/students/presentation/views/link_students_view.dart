import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/inputs/dropdown_field.dart';

class LinkStudentsView extends StatefulWidget {
  const LinkStudentsView({super.key});

  @override
  State<LinkStudentsView> createState() => _LinkStudentsViewState();
}

class _LinkStudentsViewState extends State<LinkStudentsView> {
  final _regNumberController = TextEditingController();
  final _admissionNumberController = TextEditingController();

  String? _selectedStudent;
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
      appBar: AppBar(title: const Text('Link Student(s)'), elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Link Student(s)', style: AppTextStyles.headingLarge),
              const SizedBox(height: 24),
              _buildSection(
                label: 'Registration Number',
                children: [
                  Stack(
                    children: [
                      AppTextField(
                        controller: _regNumberController,
                        hint: '8yuy5e3e46',
                        onChanged: (_) {
                          setState(() {
                            _registrationError = null;
                          });
                        },
                        label: '',
                      ),
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, size: 20),
                        ),
                      ),
                    ],
                  ),
                  if (_registrationError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _registrationError!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              _buildSection(
                label: 'Student Name',
                children: [
                  DropdownField(
                    label: 'Select student',
                    value: _selectedStudent,
                    itemLabel: (String? p1) {
                      return '';
                    },
                    items: const ['Student 1', 'Student 2', 'Student 3'],
                    onChanged: (value) {
                      setState(() {
                        _selectedStudent = value;
                        _studentError = null;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSection(
                label: 'Admission Number',
                children: [
                  AppTextField(
                    controller: _admissionNumberController,
                    hint: '8yuy5e3e46',
                    label: '',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSection(
                label: 'Student Name',
                children: [
                  DropdownField(
                    label: 'Student Name',
                    //  hintText: 'Select student',
                    value: null,
                    items: const ['Student 1', 'Student 2', 'Student 3'],
                    onChanged: (value) {},
                    itemLabel: (String? p1) {
                      return '';
                    },
                  ),
                  if (_studentError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _studentError!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add Student',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Link Student(s)',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String label,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }
}
