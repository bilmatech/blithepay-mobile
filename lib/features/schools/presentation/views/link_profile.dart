import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:blithepay/features/students/data/models/verify_student_model.dart';
import 'package:blithepay/features/students/presentation/bloc/students_bloc.dart';
import 'package:blithepay/features/students/presentation/bloc/students_event.dart';
import 'package:blithepay/features/students/presentation/bloc/students_state.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';

class LinkProfileView extends StatefulWidget {
  final VerifiedStudentModel student;

  const LinkProfileView({super.key, required this.student});

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
                child: const Icon(Icons.person, size: 80),
              ),

              const SizedBox(height: 24),

              _buildDetailBox('Full Name', widget.student.fullName),
              const Divider(),
              _buildDetailBox('School Name', widget.student.school.name),
              const Divider(),

              _buildDetailBox('Class', widget.student.classModel.name),
              const Divider(),

              const SizedBox(height: 40),
              BlocListener<StudentsBloc, StudentsState>(
                listener: (context, state) {
                  // if (state is StudentsError) {
                  //   ScaffoldMessenger.of(
                  //     context,
                  //   ).showSnackBar(SnackBar(content: Text(state.message)));
                  // }
                  if (state is StudentsLinkSuccess) {
                    // Navigate after success
                    GoRouter.of(
                      context,
                    ).push(AppRoutes.studentLinkedSuccess, extra: state.model);
                  }
                },
                child: BlocBuilder<StudentsBloc, StudentsState>(
                  builder: (context, state) {
                    final isLoading = state is StudentsLinking;

                    return PrimaryButton(
                      label: 'Link Profile',
                      onPressed: () {
                        context.read<StudentsBloc>().add(
                          LinkChildEvent(
                            studentId: widget.student.id,
                            studentCode: widget.student.school.schoolCode,
                          ),
                        );
                      },
                      isLoading: isLoading,
                    );
                  },
                ),
              ),

              // PrimaryButton(
              //   label: 'Link Profile',
              //   onPressed: () => context.push(AppRoutes.studentLinkedSuccess),
              // ),
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
