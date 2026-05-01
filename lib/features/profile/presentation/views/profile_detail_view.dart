import 'dart:io';

import 'package:blithepay/core/storage/auth_local_storage.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/arrow_button_icon.dart';
import 'package:blithepay/shared/widgets/index.dart';
import 'package:blithepay/shared/widgets/layouts/app_text.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class ProfileDetailView extends StatefulWidget {
  const ProfileDetailView({super.key});

  @override
  State<ProfileDetailView> createState() => _ProfileDetailViewState();
}

class _ProfileDetailViewState extends State<ProfileDetailView> {
  bool isEditing = false;
  File? _selectedImageFile;

  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  late final FocusNode nameFocusNode;

  String? selectedGender;
  final List<String> genderOptions = ['Male', 'Female'];

  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
    nameFocusNode = FocusNode();

    _prefillFromSession();
    context.read<ProfileBloc>().add(const GetProfileEvent());
  }

  Future<void> _prefillFromSession() async {
    final session = await context.read<AppLocalDataSource>().getSession();

    if (!mounted || session?.user == null) return;

    nameController.text =
        '${session!.user!.firstName ?? ''} ${session.user!.lastName ?? ''}'
            .trim();
    phoneController.text = session.user!.phone ?? '';
    emailController.text = session.user!.email ?? '';
  }

  Country _selectedCountry = Country(
    phoneCode: '234',
    countryCode: 'NG',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'Nigeria',
    example: '08012345678',
    displayName: 'Nigeria (NG)',
    displayNameNoCountryCode: 'Nigeria',
    e164Key: '234-NG',
  );

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        leading: BackArrowButtonIcon(
          onPressed: () {
            context.read<AppLocalDataSource>().getSession();
            context.pop();
          },
        ),
        title: const BodySm('My Profile'),
        centerTitle: true,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdated) {
            setState(() {
              isEditing = false;
            });

            // Show success dialog
            _showSuccessDialog(context);
          }

          if (state is ProfileError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const ShimmerProfileLoader();
          }

          if (state is ProfileLoaded) {
            final profile = state.profile;

            if (!_controllersInitialized) {
              nameController.text = profile['name'] ?? nameController.text;
              phoneController.text = profile['phone'] ?? phoneController.text;
              emailController.text = profile['email'] ?? emailController.text;
              _controllersInitialized = true;
              selectedGender = profile['gender'];
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BodySm('My Details'),
                  // Profile Image
                  Center(
                    child: GestureDetector(
                      onTap: isEditing ? _pickProfileImage : null,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surface,
                              border: Border.all(
                                color: AppColors.border,
                                width: 2,
                              ),
                            ),
                            child: _selectedImageFile != null
                                ? ClipOval(
                                    child: Image.file(
                                      _selectedImageFile!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: AppColors.textTertiary,
                                  ),
                          ),
                          if (isEditing)
                            Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: AppColors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Form Fields
                  AppTextField(
                    label: 'Full Name',
                    controller: nameController,
                    enabled: isEditing,
                    focusNode: nameFocusNode,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Phone Number',
                    controller: phoneController,
                    enabled: isEditing,
                    keyboardType: TextInputType.phone,
                    prefix: GestureDetector(
                      onTap: isEditing
                          ? () {
                              showCountryPicker(
                                context: context,
                                showPhoneCode: true,
                                onSelect: (Country country) {
                                  setState(() => _selectedCountry = country);
                                },
                              );
                            }
                          : null,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 12),
                          Text(
                            _selectedCountry.flagEmoji,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '+${_selectedCountry.phoneCode}',
                            style: AppTextStyles.bodyRegular,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 24,
                            width: 1,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Email',
                    controller: emailController,
                    enabled: false,
                  ),
                  const SizedBox(height: 16),
                  // Gender Dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Gender', style: AppTextStyles.bodyLarge),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: isEditing
                            ? () async {
                                if (!isEditing) return;
                                final value =
                                    await showModalBottomSheet<String>(
                                      context: context,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        ),
                                      ),
                                      builder: (context) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: genderOptions.map((gender) {
                                            return ListTile(
                                              title: Text(gender),
                                              onTap: () => Navigator.pop(
                                                context,
                                                gender,
                                              ),
                                            );
                                          }).toList(),
                                        );
                                      },
                                    );

                                if (value != null) {
                                  setState(() => selectedGender = value);
                                }
                              }
                            : null,
                        child: Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  selectedGender ?? 'Select Gender',
                                  style: AppTextStyles.bodyRegular.copyWith(
                                    color: selectedGender == null
                                        ? AppColors.textSecondary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Update Profile Button
                  PrimaryButton(
                    label: isEditing ? 'Update Profile' : 'Edit Profile',
                    onPressed: () {
                      if (isEditing) {
                        context.read<ProfileBloc>().add(
                          UpdateProfileEvent(
                            name: nameController.text.trim(),
                            phone: phoneController.text.trim(),
                            gender: selectedGender,
                            profileImagePath: _selectedImageFile?.path,
                          ),
                        );
                      } else {
                        setState(() => isEditing = true);
                        Future.microtask(() => nameFocusNode.requestFocus());
                      }
                    },
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _pickProfileImage() async {
    // For now, using a simple approach to show image selection
    // In a real app, you'd use image_picker package
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement gallery picker
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement camera picker
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: AppColors.white, size: 48),
            ),
            const SizedBox(height: 24),

            const Text(
              'You have successfully updated your profile',
              style: AppTextStyles.bodyRegular,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Done',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
