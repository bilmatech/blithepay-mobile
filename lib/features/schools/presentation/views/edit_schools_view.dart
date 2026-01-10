import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class EditSchoolsView extends StatefulWidget {
  const EditSchoolsView({super.key});

  @override
  State<EditSchoolsView> createState() => _EditSchoolsViewState();
}

class _EditSchoolsViewState extends State<EditSchoolsView> {
  late TextEditingController _schoolCodeController;
  late TextEditingController _schoolNameController;

  @override
  void initState() {
    super.initState();
    _schoolCodeController = TextEditingController();
    _schoolNameController = TextEditingController();
  }

  @override
  void dispose() {
    _schoolCodeController.dispose();
    _schoolNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Schools'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Added Schools:', style: AppTextStyles.heading2),
            const SizedBox(height: 12),
            _SchoolListItem(
              name: 'Ijesha International Nursery & Primary School',
              onEdit: () {
                context.push('/edit-school/1');
              },
            ),
            const SizedBox(height: 8),
            _SchoolListItem(
              name: 'Pascal Nursery & Primary School',
              onEdit: () {
                context.push('/edit-school/2');
              },
            ),
            const SizedBox(height: 32),
            const Text('Add School', style: AppTextStyles.heading2),
            const SizedBox(height: 16),
            AppTextField(
              label: 'School Code',
              hint: 'Enter school code',
              controller: _schoolCodeController,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'School Name',
              hint: 'Select school',
              controller: _schoolNameController,
              //  readOnly: true,
              suffixIcon: const Icon(Icons.arrow_drop_down),
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: 'Add School', onPressed: () {}),
          ],
        ),
      ),
    );
  }
}

class _SchoolListItem extends StatelessWidget {
  final String name;
  final VoidCallback onEdit;

  const _SchoolListItem({required this.name, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(name, style: AppTextStyles.bodyMedium)),
          IconButton(
            icon: const Icon(Icons.edit),
            color: AppColors.primary,
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}
