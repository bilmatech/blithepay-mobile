import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:blithepay/features/schools/data/models/school_model.dart';
import 'package:blithepay/features/schools/presentation/bloc/schools_bloc.dart';
import 'package:blithepay/features/schools/presentation/bloc/schools_event.dart';
import 'package:blithepay/features/schools/presentation/bloc/schools_state.dart';
import 'package:blithepay/features/students/presentation/bloc/students_bloc.dart';
import 'package:blithepay/features/students/presentation/bloc/students_event.dart';
import 'package:blithepay/features/students/presentation/bloc/students_state.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/arrow_button_icon.dart';
import 'package:blithepay/shared/widgets/layouts/app_text.dart';
import 'package:blithepay/shared/widgets/layouts/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';

class LinkChildSchoolView extends StatefulWidget {
  const LinkChildSchoolView({super.key});

  @override
  State<LinkChildSchoolView> createState() => _LinkChildSchoolViewState();
}

class _LinkChildSchoolViewState extends State<LinkChildSchoolView> {
  final _regNumberController = TextEditingController();
  final _admissionNumberController = TextEditingController();
  final _searchController = TextEditingController();
  String _searchQuery = '';

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
      appBar: AppBar(
        leading: const BackArrowButtonIcon(),
        title: const HeadingLg('Service'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HeadingXl('Add Child', color: AppColors.primary),
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
                    label: 'Enter School Registration No',
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
              // SEARCH FIELD
              AppTextField(
                controller: _searchController,
                hint: 'Search schools Name...',
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase().trim();
                  });
                },

                label: '',
              ),

              const VSpaceXxl(),

              const HeadingSm('Select School'),
              const VSpaceLg(),

              BlocBuilder<SchoolsBloc, SchoolsState>(
                builder: (context, state) {
                  if (state is SchoolsLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (state is SchoolsError) {
                    return Text(state.message);
                  }

                  if (state is SchoolsLoaded) {
                    final filteredSchools = state.schools.where((school) {
                      final name = (school.displayName ?? '').toLowerCase();
                      return name.contains(_searchQuery);
                    }).toList();

                    if (filteredSchools.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No schools found'),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredSchools.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        final school = filteredSchools[index];

                        return InkWell(
                          onTap: _regNumberController.text.trim().isEmpty
                              ? null
                              : () {
                                  setState(() {
                                    _selectedSchool = school;
                                  });

                                  _verifyAndLinkChild();
                                },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 24,
                            ),
                            decoration: BoxDecoration(
                              color: _selectedSchool?.id == school.id
                                  ? Colors.grey.withValues(alpha: 0.05)
                                  : Colors.white,
                              border: Border.all(color: Colors.grey.shade100),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                // LOGO
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                    borderRadius: BorderRadius.circular(4),

                                    // shape: BoxShape.circle,
                                    // color: Colors.grey.shade200,
                                  ),
                                  child: school.logo == null
                                      ? const Icon(Icons.school)
                                      : Image.network(
                                          school.logo!,
                                          scale: 0.5,
                                          fit: BoxFit.cover,
                                        ),
                                ),

                                const SizedBox(width: 12),

                                // NAME
                                Expanded(
                                  child: BodyLg(school.displayName ?? ''),
                                ),

                                const Icon(Icons.arrow_forward_ios, size: 16),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return const SizedBox();
                },
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

                  if (state is VerifyStudentS) {
                    // show "Verifying..." UI state
                    setState(() {});
                  }

                  if (state is VerifyStudentSuccess) {
                    final student = state.model;
                    GoRouter.of(
                      context,
                    ).push(AppRoutes.linkProfile, extra: student);
                  }
                },
                child: const SizedBox(),
              ),
              // BlocListener<StudentsBloc, StudentsState>(
              //   listener: (context, state) {
              //     if (state is StudentsError) {
              //       ScaffoldMessenger.of(
              //         context,
              //       ).showSnackBar(SnackBar(content: Text(state.message)));
              //     }
              //     if (state is VerifyStudentSuccess) {
              //       print(state.model?.fullName);
              //       final student = state.model;
              //       GoRouter.of(
              //         context,
              //       ).push(AppRoutes.linkProfile, extra: student);
              //     }
              //   },
              //   child: BlocBuilder<StudentsBloc, StudentsState>(
              //     builder: (context, state) {
              //       final isLoading = state is VerifyStudentS;
              //       return PrimaryButton(
              //         label: 'Verify',
              //         onPressed: _verifyAndLinkChild,
              //         isLoading: isLoading,
              //       );
              //     },
              //   ),
              // ),
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
