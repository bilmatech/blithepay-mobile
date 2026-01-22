import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/inputs/dropdown_field.dart';

class LinkChildSchoolView extends StatefulWidget {
  const LinkChildSchoolView({super.key});

  @override
  State<LinkChildSchoolView> createState() => _LinkChildSchoolViewState();
}

class _LinkChildSchoolViewState extends State<LinkChildSchoolView> {
  final _regNumberController = TextEditingController();
  final _admissionNumberController = TextEditingController();

  String? _selectedSchool;
  String? _registrationError;

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
              const Text('Link Child', style: AppTextStyles.headingLarge),
              const SizedBox(height: 24),
              _buildSection(
                label: '',
                children: [
                  AppTextField(
                    controller: _regNumberController,
                    hint: '8yuy5e3e46',
                    onChanged: (_) {
                      setState(() {
                        _registrationError = null;
                      });
                    },
                    label: 'Student ID Number',
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
                        _selectedSchool ?? 'Select option',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const Icon(Icons.arrow_drop_down_outlined),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Verify',
                onPressed: () => context.push(AppRoutes.linkProfile),
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
