import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:blithepay/features/schools/data/models/school_model.dart';
import 'package:blithepay/features/schools/presentation/bloc/schools_bloc.dart';
import 'package:blithepay/features/schools/presentation/bloc/schools_event.dart';
import 'package:blithepay/features/schools/presentation/bloc/schools_state.dart';
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

  SchoolModel? _selectedSchool;
  String? _registrationError;

  @override
  void initState() {
    super.initState();

    context.read<SchoolsBloc>().add(
      const GetSchoolPortalEvent(page: 1, limit: 20),
    );
  }

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
                _selectedSchool?.name ?? 'Select school',
                style: AppTextStyles.bodyLarge,
              ),
              const SizedBox(height: 8),

              GestureDetector(
                onTap: () {
                  final bloc = context.read<SchoolsBloc>();
                  final state = bloc.state;

                  if (state is SchoolsLoading) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Loading schools...')),
                    );
                    return;
                  }

                  if (state is SchoolsLoaded) {
                    if (state.schools.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No schools available')),
                      );
                      return;
                    }

                    showItemSelectionSheet<SchoolModel>(
                      context: context,
                      title: 'Select School',
                      items: state.schools,
                      selectedItem: _selectedSchool,
                      itemLabel: (school) => school.name,
                      onItemSelected: (school) {
                        setState(() {
                          _selectedSchool = school;
                        });
                      },
                      onReachedBottom: () {
                        if (state.nextPage != null && !state.isFetchingMore) {
                          bloc.add(const GetSchoolPortalEvent());
                        }
                      },
                    );
                  }

                  if (state is SchoolsError) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  }
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
                        _selectedSchool?.displayName ?? 'Select School',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const Icon(Icons.arrow_drop_down_outlined),
                    ],
                  ),
                ),
              ),

              // GestureDetector(
              //   onTap: () {
              //     showItemSelectionSheet<String>(
              //       context: context,
              //       title: 'Select School',
              //       items: [
              //         'Greenwood High',
              //         'Hillview Academy',
              //         'Sunrise School',
              //       ],
              //       selectedItem: _selectedSchool?.name,
              //       onItemSelected: (school) {
              //         setState(() {
              //           _selectedSchool = school;
              //         });
              //       },
              //     );
              //   },
              //   child: Container(
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 16,
              //       vertical: 14,
              //     ),
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(12),
              //       border: Border.all(color: Colors.grey.shade300),
              //     ),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Text(
              //           _selectedSchool?.name ?? 'Select option',
              //           style: const TextStyle(fontSize: 14),
              //         ),
              //         const Icon(Icons.arrow_drop_down_outlined),
              //       ],
              //     ),
              //   ),
              // ),
              const SizedBox(height: 20),
              BlocListener<StudentsBloc, StudentsState>(
                listener: (context, state) {
                  if (state is StudentsError) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                  if (state is VerifyStudentSuccess) {
                    print(state.model?.fullName);
                    final student = state.model;
                    GoRouter.of(
                      context,
                    ).push(AppRoutes.linkProfile, extra: student);
                  }
                },
                child: BlocBuilder<StudentsBloc, StudentsState>(
                  builder: (context, state) {
                    final isLoading = state is VerifyStudentS;
                    return PrimaryButton(
                      label: 'Verify',
                      onPressed: _verifyAndLinkChild,
                      isLoading: isLoading,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _verifyAndLinkChild() {
    final regNum = _regNumberController.text.trim();

    if (regNum.isEmpty) {
      setState(() {
        _registrationError = 'Student ID is required';
      });
      return;
    }

    if (_selectedSchool == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a school')));
      return;
    }

    context.read<StudentsBloc>().add(
      VerifyChildEvent(
        schoolId: _selectedSchool?.id ?? '',
        regNum: regNum,
        studentCode: _selectedSchool!.schoolCode,
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
