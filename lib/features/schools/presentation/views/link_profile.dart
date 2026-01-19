import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';

class LinkProfileView extends StatefulWidget {
  const LinkProfileView({super.key});

  @override
  State<LinkProfileView> createState() => _LinkProfileViewState();
}

class _LinkProfileViewState extends State<LinkProfileView> {
  final _regNumberController = TextEditingController();
  final _admissionNumberController = TextEditingController();

  // String? _selectedSchool;
  // String? _registrationError;
  // String? _studentError;

  @override
  void dispose() {
    _regNumberController.dispose();
    _admissionNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Link Child'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 1),
                  // image: const DecorationImage(
                  //   image: NetworkImage(
                  //     'https://placehold.co', // child image url
                  //   ),
                  //   fit: BoxFit.cover,
                  // ),
                ),
                child: Icon(Icons.person, size: 80),
              ),

              const SizedBox(height: 24),

              _buildDetailBox('Full Name', 'Adebowale Anthony Joshua'),
              Divider(),
              _buildDetailBox('School Name', 'Adebowale School'),
              Divider(),

              _buildDetailBox('Class', 'Primary 3'),
              Divider(),

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

  Widget _buildDetailBox(String title, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: AppTextStyles.bodyRegularBlack.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyRegular.copyWith(
                color: AppColors.lightBack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
