import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/dialogs/confirmation_dialog.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class EditSchoolDetailView extends StatefulWidget {
  final String schoolId;

  const EditSchoolDetailView({super.key, required this.schoolId});

  @override
  State<EditSchoolDetailView> createState() => _EditSchoolDetailViewState();
}

class _EditSchoolDetailViewState extends State<EditSchoolDetailView> {
  late TextEditingController _schoolCodeController;
  late TextEditingController _schoolNameController;

  @override
  void initState() {
    super.initState();
    _schoolCodeController = TextEditingController(text: '8yuy5e3e46');
    _schoolNameController = TextEditingController(
      text: 'Ijesha International Nursery & Primary School',
    );
  }

  @override
  void dispose() {
    _schoolCodeController.dispose();
    _schoolNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Edit Schools'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Edit >> ',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Ijesha International Nursery & Primary School',
                    style: AppTextStyles.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
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
            PrimaryButton(label: 'Save Changes', onPressed: () {}),
            const SizedBox(height: 24),
            Center(
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => ConfirmationDialog(
                      title: 'Delete School',
                      message:
                          'Are you sure? You will need to attach your student(s) to a different school.',
                      confirmLabel: 'Yes, Delete',
                      cancelLabel: 'No, Cancel',
                      isDangerous: true,
                      onConfirm: () {
                        context.pop();
                      },
                    ),
                  );
                },
                child: Text(
                  'Delete School',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
