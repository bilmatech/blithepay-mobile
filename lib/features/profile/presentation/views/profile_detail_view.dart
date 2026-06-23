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
import 'package:image_picker/image_picker.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

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
import 'package:image_picker/image_picker.dart';
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
  File? _selectedImageFile;

  // The Single Source of Truth for the profile picture URL
  String _profileImageUrl = '';

  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;

  bool _hasFormChanges = false;
  String _initialName = '';
  String _initialPhone = '';

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController()..addListener(_checkForChanges);
    phoneController = TextEditingController()..addListener(_checkForChanges);
    emailController = TextEditingController();

    // 1. Instantly pull everything available from local storage
    _prefillFromSession();
    // 2. Refresh from server network data
    context.read<ProfileBloc>().add(const GetProfileEvent());
  }

  void _checkForChanges() {
    final changed =
        nameController.text.trim() != _initialName ||
        phoneController.text.trim() != _initialPhone;

    if (changed != _hasFormChanges) {
      setState(() => _hasFormChanges = changed);
    }
  }

  Future<void> _prefillFromSession() async {
    final session = await context.read<AppLocalDataSource>().getSession();
    if (!mounted || session?.user == null) return;

    setState(() {
      _initialName =
          '${session!.user!.firstName ?? ''} ${session.user!.lastName ?? ''}'
              .trim();
      _initialPhone = session.user!.phone ?? '';

      nameController.text = _initialName;
      phoneController.text = _initialPhone;
      emailController.text = session.user!.email ?? '';
      print(session.user!.profileImage);
      // Map picture from local session immediately on screen boot
      if (session.user!.profileImage != null &&
          session.user!.profileImage!.isNotEmpty) {
        _profileImageUrl = session.user!.profileImage!;
      }
    });
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
    nameController.removeListener(_checkForChanges);
    phoneController.removeListener(_checkForChanges);
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          setState(() {
            // Update the single source of truth URL from server map payload
            if (state.profile['picture'] != null &&
                state.profile['picture']!.isNotEmpty) {
              _profileImageUrl = state.profile['picture']!;
            }

            // Update text baselines safely if user hasn't typed anything new
            if (!_hasFormChanges) {
              _initialName = state.profile['name'] ?? _initialName;
              _initialPhone = state.profile['phone'] ?? _initialPhone;

              nameController.text = _initialName;
              phoneController.text = _initialPhone;
            }
            emailController.text =
                state.profile['email'] ?? emailController.text;

            // Image uploaded completely, clear the local file indicator track
            _selectedImageFile = null;
            _hasFormChanges = false;
          });
        }
        if (state is ProfileUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
        if (state is ProfileError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final isSubmitting = state is ProfileLoading;

        // Show shimmer only if we have absolute zero data loaded anywhere yet
        final isInitialLoad =
            state is ProfileLoading &&
            nameController.text.isEmpty &&
            _profileImageUrl.isEmpty;

        if (isInitialLoad) {
          return const AppScaffold(body: ShimmerProfileLoader());
        }

        return AppScaffold(
          appBar: AppBar(
            leading: BackArrowButtonIcon(onPressed: () => context.pop()),
            title: const BodySm('My Profile'),
            centerTitle: true,
            // Inside ProfileDetailView AppBar actions array:
            actions: [
              if (_hasFormChanges)
                isSubmitting
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    : TextButton(
                        onPressed: () {
                          context.read<ProfileBloc>().add(
                            UpdateProfileEvent(
                              name: nameController.text.trim(),
                              phone: phoneController.text.trim(),
                              // DO NOT send null here blindly anymore!
                              profileImagePath: _selectedImageFile?.path,
                            ),
                          );
                        },
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BodySm('My Details'),
                const SizedBox(height: 16),

                // Unified Modern Avatar Selector
                Center(
                  child: GestureDetector(
                    onTap: isSubmitting ? null : _pickProfileImage,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surface,
                            border: Border.all(
                              color: isSubmitting
                                  ? AppColors.primary.withValues(alpha: 0.3)
                                  : AppColors.border,
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
                              : _profileImageUrl.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    _profileImageUrl,
                                    fit: BoxFit.cover,
                                    key: ValueKey(
                                      _profileImageUrl,
                                    ), // Forces image refresh instantly when URL shifts
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.person, size: 44),
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 44,
                                  color: AppColors.textTertiary,
                                ),
                        ),

                        // Circular indicator over avatar when updating image path explicitly
                        if (isSubmitting && _selectedImageFile != null)
                          const SizedBox(
                            width: 90,
                            height: 90,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),

                        if (!isSubmitting)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 14,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                AppTextField(
                  label: 'Full Name',
                  controller: nameController,
                  enabled: !isSubmitting,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Phone Number',
                  controller: phoneController,
                  enabled: !isSubmitting,
                  keyboardType: TextInputType.phone,
                  prefix: GestureDetector(
                    onTap: !isSubmitting
                        ? () {
                            showCountryPicker(
                              context: context,
                              showPhoneCode: true,
                              onSelect: (Country country) {
                                setState(() => _selectedCountry = country);
                                _checkForChanges();
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
              ],
            ),
          ),
        );
      },
    );
  }

  void _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() => _selectedImageFile = File(image.path));

      if (!mounted) return;
      context.read<ProfileBloc>().add(
        UpdateProfileEvent(
          name: nameController.text.trim(),
          phone: phoneController.text.trim(),
          profileImagePath: image.path,
        ),
      );
    }
  }
}

// class ProfileDetailView extends StatefulWidget {
//   const ProfileDetailView({super.key});

//   @override
//   State<ProfileDetailView> createState() => _ProfileDetailViewState();
// }

// class _ProfileDetailViewState extends State<ProfileDetailView> {
//   bool isEditing = false;
//   File? _selectedImageFile;

//   Map<String, dynamic>? _cachedProfile;

//   late final TextEditingController nameController;
//   late final TextEditingController phoneController;
//   late final TextEditingController emailController;
//   late final FocusNode nameFocusNode;

//   bool _controllersInitialized = false;

//   @override
//   void initState() {
//     super.initState();

//     nameController = TextEditingController();
//     phoneController = TextEditingController();
//     emailController = TextEditingController();
//     nameFocusNode = FocusNode();

//     _prefillFromSession();
//     context.read<ProfileBloc>().add(const GetProfileEvent());
//   }

//   Future<void> _prefillFromSession() async {
//     final session = await context.read<AppLocalDataSource>().getSession();

//     if (!mounted || session?.user == null) return;

//     nameController.text =
//         '${session!.user!.firstName ?? ''} ${session.user!.lastName ?? ''}'
//             .trim();
//     phoneController.text = session.user!.phone ?? '';
//     emailController.text = session.user!.email ?? '';
//   }

//   Country _selectedCountry = Country(
//     phoneCode: '234',
//     countryCode: 'NG',
//     e164Sc: 0,
//     geographic: true,
//     level: 1,
//     name: 'Nigeria',
//     example: '08012345678',
//     displayName: 'Nigeria (NG)',
//     displayNameNoCountryCode: 'Nigeria',
//     e164Key: '234-NG',
//   );

//   @override
//   void dispose() {
//     nameController.dispose();
//     phoneController.dispose();
//     emailController.dispose();
//     nameFocusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AppScaffold(
//       appBar: AppBar(
//         leading: BackArrowButtonIcon(
//           onPressed: () {
//             context.read<AppLocalDataSource>().getSession();
//             context.pop();
//           },
//         ),
//         title: const BodySm('My Profile'),
//         centerTitle: true,
//       ),
//       body: BlocConsumer<ProfileBloc, ProfileState>(
//         listener: (context, state) {
//           if (state is ProfileUpdated) {
//             setState(() {
//               isEditing = false;
//             });
//             _showSuccessDialog(context);
//           }

//           if (state is ProfileError) {
//             ScaffoldMessenger.of(
//               context,
//             ).showSnackBar(SnackBar(content: Text(state.message)));
//           }
//         },
//         builder: (context, state) {
//           if (state is ProfileLoaded) {
//             _cachedProfile = state.profile;
//           }

//           final isSubmitting = state is ProfileLoading && isEditing;
//           final isInitialLoad =
//               state is ProfileLoading && _cachedProfile == null;

//           if (isInitialLoad) {
//             return const ShimmerProfileLoader();
//           }

//           if (_cachedProfile != null) {
//             if (!_controllersInitialized) {
//               nameController.text =
//                   _cachedProfile!['name'] ?? nameController.text;
//               phoneController.text =
//                   _cachedProfile!['phone'] ?? phoneController.text;
//               emailController.text =
//                   _cachedProfile!['email'] ?? emailController.text;
//               _controllersInitialized = true;
//             }

//             return SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const BodySm('My Details'),

//                   Center(
//                     child: GestureDetector(
//                       onTap: (isEditing && !isSubmitting)
//                           ? _pickProfileImage
//                           : null,
//                       child: Stack(
//                         alignment: Alignment.bottomRight,
//                         children: [
//                           Container(
//                             width: 80,
//                             height: 80,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: AppColors.surface,
//                               border: Border.all(
//                                 color: AppColors.border,
//                                 width: 2,
//                               ),
//                             ),
//                             child: _selectedImageFile != null
//                                 ? ClipOval(
//                                     child: Image.file(
//                                       _selectedImageFile!,
//                                       fit: BoxFit.cover,
//                                     ),
//                                   )
//                                 : (_cachedProfile!['picture'] != null &&
//                                       _cachedProfile!['picture']!.isNotEmpty)
//                                 ? ClipOval(
//                                     child: Image.network(
//                                       _cachedProfile!['picture']!,
//                                       fit: BoxFit.cover,
//                                       errorBuilder:
//                                           (context, error, stackTrace) =>
//                                               const Icon(
//                                                 Icons.person,
//                                                 size: 40,
//                                               ),
//                                     ),
//                                   )
//                                 : const Icon(
//                                     Icons.person,
//                                     size: 40,
//                                     color: AppColors.textTertiary,
//                                   ),
//                           ),
//                           if (isEditing && !isSubmitting)
//                             Container(
//                               width: 36,
//                               height: 36,
//                               decoration: const BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: AppColors.primary,
//                               ),
//                               child: const Icon(
//                                 Icons.camera_alt,
//                                 size: 18,
//                                 color: AppColors.white,
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 32),
//                   // Form Fields
//                   AppTextField(
//                     label: 'Full Name',
//                     controller: nameController,
//                     enabled: isEditing && !isSubmitting,
//                     focusNode: nameFocusNode,
//                   ),
//                   const SizedBox(height: 16),
//                   AppTextField(
//                     label: 'Phone Number',
//                     controller: phoneController,
//                     enabled: isEditing && !isSubmitting,
//                     keyboardType: TextInputType.phone,
//                     prefix: GestureDetector(
//                       onTap: (isEditing && !isSubmitting)
//                           ? () {
//                               showCountryPicker(
//                                 context: context,
//                                 showPhoneCode: true,
//                                 onSelect: (Country country) {
//                                   setState(() => _selectedCountry = country);
//                                 },
//                               );
//                             }
//                           : null,
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const SizedBox(width: 12),
//                           Text(
//                             _selectedCountry.flagEmoji,
//                             style: const TextStyle(fontSize: 18),
//                           ),
//                           const SizedBox(width: 6),
//                           Text(
//                             '+${_selectedCountry.phoneCode}',
//                             style: AppTextStyles.bodyRegular,
//                           ),
//                           const SizedBox(width: 8),
//                           Container(
//                             height: 24,
//                             width: 1,
//                             color: AppColors.textTertiary,
//                           ),
//                           const SizedBox(width: 8),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   AppTextField(
//                     label: 'Email',
//                     controller: emailController,
//                     enabled: false,
//                   ),
//                   const SizedBox(height: 32),

//                   // Update Profile Button
//                   PrimaryButton(
//                     isLoading:
//                         isSubmitting, // 4. Only the button gets the loading state feedback!
//                     label: isEditing ? 'Update Profile' : 'Edit Profile',
//                     onPressed: isSubmitting
//                         ? () {}
//                         : () {
//                             if (isEditing) {
//                               context.read<ProfileBloc>().add(
//                                 UpdateProfileEvent(
//                                   name: nameController.text.trim(),
//                                   phone: phoneController.text.trim(),
//                                   profileImagePath: _selectedImageFile?.path,
//                                 ),
//                               );
//                             } else {
//                               setState(() => isEditing = true);
//                               Future.microtask(
//                                 () => nameFocusNode.requestFocus(),
//                               );
//                             }
//                           },
//                   ),
//                 ],
//               ),
//             );
//           }

//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }

//   void _pickProfileImage() async {
//     final ImagePicker picker = ImagePicker();

//     showModalBottomSheet(
//       context: context,
//       builder: (context) => Container(
//         color: AppColors.white,
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.photo_library),
//               title: const Text('Choose from gallery'),
//               onTap: () async {
//                 Navigator.pop(context);
//                 final XFile? image = await picker.pickImage(
//                   source: ImageSource.gallery,
//                   imageQuality: 80,
//                 );
//                 if (image != null) {
//                   setState(() => _selectedImageFile = File(image.path));
//                 }
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.camera_alt),
//               title: const Text('Take a photo'),
//               onTap: () async {
//                 Navigator.pop(context);
//                 final XFile? image = await picker.pickImage(
//                   source: ImageSource.camera,
//                   imageQuality: 80,
//                 );
//                 if (image != null) {
//                   setState(() => _selectedImageFile = File(image.path));
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showSuccessDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const SizedBox(height: 24),
//             Container(
//               width: 80,
//               height: 80,
//               decoration: const BoxDecoration(
//                 color: AppColors.success,
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(Icons.check, color: AppColors.white, size: 48),
//             ),
//             const SizedBox(height: 24),

//             const Text(
//               'You have successfully updated your profile',
//               style: AppTextStyles.bodyRegular,
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 32),
//             PrimaryButton(
//               label: 'Done',
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//             ),
//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }
// }
