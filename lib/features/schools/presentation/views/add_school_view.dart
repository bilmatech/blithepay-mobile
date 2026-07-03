import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/inputs/dropdown_field.dart';

class AddSchoolView extends StatefulWidget {
  const AddSchoolView({super.key});

  @override
  State<AddSchoolView> createState() => _AddSchoolViewState();
}

class _AddSchoolViewState extends State<AddSchoolView> {
  final _schoolCodeController = TextEditingController();
  String? _selectedSchool;

  @override
  void dispose() {
    _schoolCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Add School'), elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add School', style: AppTextStyles.headingLarge),
              const SizedBox(height: 24),
              Text(
                'School Code',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _schoolCodeController,
                hint: '8yuy5e3e46',
                label: '',
              ),
              const SizedBox(height: 20),
              Text(
                'School Name',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownField(
                label: 'Select school',
                itemLabel: (String? p1) {
                  return '';
                },
                value: _selectedSchool,
                items: const [
                  'Seaman International Nursery & Primary School',
                  'Lagos State Model School',
                  'British International School',
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedSchool = value;
                  });
                },
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Add School',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
