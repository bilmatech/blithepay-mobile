import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:blithepay/features/schools/data/models/school_model.dart';
import 'package:blithepay/features/schools/presentation/bloc/schools_bloc.dart';
import 'package:blithepay/features/schools/presentation/bloc/schools_event.dart';
import 'package:blithepay/features/schools/presentation/bloc/schools_state.dart';
import 'package:blithepay/features/students/data/models/verify_student_model.dart';
import 'package:blithepay/features/students/presentation/bloc/students_bloc.dart';
import 'package:blithepay/features/students/presentation/bloc/students_event.dart';
import 'package:blithepay/features/students/presentation/bloc/students_state.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/arrow_button_icon.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
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
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isRegNumberEmpty = true;

  SchoolModel? _selectedSchool;
  VerifiedStudentModel? _verifiedStudent;
  bool _isVerifying = false;
  bool _isLinking = false;
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
    _searchController.dispose();
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
        child: BlocListener<StudentsBloc, StudentsState>(
          listener: (context, state) {
            if (state is StudentsError) {
              setState(() {
                _isVerifying = false;
                _isLinking = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.error,
                ),
              );
            }

            if (state is VerifyStudentS) {
              setState(() {
                _isVerifying = true;
                _verifiedStudent = null;
              });
            }

            if (state is VerifyStudentSuccess) {
              setState(() {
                _isVerifying = false;
                _verifiedStudent = state.model;
              });
            }

            if (state is StudentsLinking) {
              setState(() {
                _isLinking = true;
              });
            }

            if (state is StudentsLinkSuccess) {
              setState(() {
                _isLinking = false;
              });
              if (state.model != null) {
                GoRouter.of(context).pushReplacement(
                  AppRoutes.studentLinkedSuccess,
                  extra: state.model,
                );
              }
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeadingXl('Add Child', color: AppColors.primary),
                const VSpaceBase(),
                
                // Step 1: School Registration Number
                AppTextField(
                  controller: _regNumberController,
                  hint: '8yuy5e3e46',
                  onChanged: (val) {
                    setState(() {
                      _registrationError = null;
                      _isRegNumberEmpty = val.trim().isEmpty;
                      if (_isRegNumberEmpty) {
                        _selectedSchool = null;
                        _verifiedStudent = null;
                      }
                    });
                  },
                  label: 'Enter School Registration No',
                  enabled: !_isVerifying && !_isLinking,
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

                // Step 2: Search & Select School (Visual flow toggle)
                if (_verifiedStudent == null && !_isVerifying) ...[
                  const VSpaceXxl(),
                  IgnorePointer(
                    ignoring: _isRegNumberEmpty,
                    child: AnimatedOpacity(
                      opacity: _isRegNumberEmpty ? 0.4 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppTextField(
                            controller: _searchController,
                            hint: 'Search schools Name...',
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value.toLowerCase().trim();
                              });
                            },
                            label: 'Select School',
                            prefix: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                            ),
                            enabled: !_isRegNumberEmpty,
                          ),
                          const VSpaceLg(),
                          BlocBuilder<SchoolsBloc, SchoolsState>(
                            builder: (context, state) {
                              if (state is SchoolsLoading) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 32),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                    ),
                                  ),
                                );
                              }

                              if (state is SchoolsError) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    child: Text(
                                      state.message,
                                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                                    ),
                                  ),
                                );
                              }

                              if (state is SchoolsLoaded) {
                                final filteredSchools = state.schools.where((school) {
                                  final name = (school.displayName ?? school.name).toLowerCase();
                                  return name.contains(_searchQuery);
                                }).toList();

                                if (filteredSchools.isEmpty) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 32),
                                      child: Text(
                                        'No schools found',
                                        style: AppTextStyles.bodyMedium,
                                      ),
                                    ),
                                  );
                                }

                                return Container(
                                  height: 300,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.border.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: ListView.separated(
                                      padding: const EdgeInsets.all(12),
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: filteredSchools.length,
                                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                                      itemBuilder: (context, index) {
                                        final school = filteredSchools[index];
                                        final isSelected = _selectedSchool?.id == school.id;

                                        return InkWell(
                                          onTap: () {
                                            setState(() {
                                              _selectedSchool = school;
                                            });
                                            _verifyAndLinkChild();
                                          },
                                          borderRadius: BorderRadius.circular(16),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 16,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.primary.withValues(alpha: 0.05)
                                                  : Colors.white,
                                              border: Border.all(
                                                color: isSelected
                                                    ? AppColors.primary.withValues(alpha: 0.3)
                                                    : AppColors.border.withValues(alpha: 0.6),
                                                width: isSelected ? 1.5 : 1.0,
                                              ),
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: isSelected
                                                  ? [
                                                      BoxShadow(
                                                        color: AppColors.primary.withValues(alpha: 0.05),
                                                        blurRadius: 8,
                                                        offset: const Offset(0, 4),
                                                      )
                                                    ]
                                                  : null,
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(8),
                                                  height: 48,
                                                  width: 48,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(
                                                      color: isSelected
                                                          ? AppColors.primary.withValues(alpha: 0.2)
                                                          : AppColors.border.withValues(alpha: 0.6),
                                                    ),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: school.logo == null
                                                      ? const Icon(
                                                          Icons.school_rounded,
                                                          color: AppColors.primary,
                                                          size: 24,
                                                        )
                                                      : Image.network(
                                                          school.logo!,
                                                          fit: BoxFit.contain,
                                                          errorBuilder: (_, __, ___) => const Icon(
                                                            Icons.school_rounded,
                                                            color: AppColors.primary,
                                                          ),
                                                        ),
                                                ),
                                                const SizedBox(width: 14),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        school.displayName ?? school.name,
                                                        style: AppTextStyles.bodyRegularBlack.copyWith(
                                                          fontWeight: FontWeight.bold,
                                                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        'School Code: ${school.schoolCode}',
                                                        style: AppTextStyles.caption.copyWith(
                                                          color: AppColors.textSecondary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.arrow_forward_ios_rounded,
                                                  size: 14,
                                                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              }

                              return const SizedBox();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Verification Loader State
                if (_isVerifying) ...[
                  const VSpaceXxl(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Verifying student details at\n${_selectedSchool?.displayName ?? _selectedSchool?.name ?? ''}...',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],

                // Step 3: Redesigned verified child info card
                if (_verifiedStudent != null) ...[
                  const VSpaceXxl(),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          color: AppColors.success.withValues(alpha: 0.04),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'STUDENT DETECTED',
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.success.withValues(alpha: 0.25),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: AppColors.success,
                                      size: 13,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'VERIFIED',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Color(0xFFE0E7FF), Color(0xFFC7D2FE)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${_verifiedStudent!.firstName.isNotEmpty ? _verifiedStudent!.firstName[0] : ''}'
                                        '${_verifiedStudent!.lastName.isNotEmpty ? _verifiedStudent!.lastName[0] : ''}',
                                        style: AppTextStyles.headingLarge.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _verifiedStudent!.fullName,
                                          style: AppTextStyles.headingMedium.copyWith(
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.class_rounded,
                                              size: 13,
                                              color: AppColors.textSecondary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Class: ${_verifiedStudent!.classModel.name}',
                                              style: AppTextStyles.bodySmall.copyWith(
                                                color: AppColors.textSecondary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const Divider(height: 1, color: AppColors.border),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                icon: Icons.school_rounded,
                                label: 'School Name',
                                value: _verifiedStudent!.school.displayName ?? _verifiedStudent!.school.name,
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                icon: Icons.badge_rounded,
                                label: 'Reg Number',
                                value: _verifiedStudent!.regNumber,
                              ),
                              const SizedBox(height: 20),
                              
                              // Change School / Reg No Action
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _verifiedStudent = null;
                                      _selectedSchool = null;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.edit_rounded,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                  label: Text(
                                    'Change School / ID',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    backgroundColor: AppColors.primary.withValues(alpha: 0.05),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const VSpaceXxl(),
                  
                  // Link Child Action Button
                  PrimaryButton(
                    label: 'Link Child',
                    isLoading: _isLinking,
                    onPressed: () {
                      context.read<StudentsBloc>().add(
                        LinkChildEvent(
                          studentId: _verifiedStudent!.id,
                          studentCode: _verifiedStudent!.school.schoolCode,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a school')),
      );
      return;
    }

    context.read<StudentsBloc>().add(
      VerifyChildEvent(
        schoolId: _selectedSchool!.id,
        regNum: regNum,
        studentCode: _selectedSchool!.schoolCode,
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
