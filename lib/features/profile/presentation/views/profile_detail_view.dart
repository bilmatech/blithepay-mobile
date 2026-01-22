import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/index.dart';
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
  bool isEditing = false; // Track edit mode
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late FocusNode nameFocusNode;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const GetProfileEvent());
    nameController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
    nameFocusNode = FocusNode();
  }

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const ShimmerProfileLoader();
          } else if (state is ProfileLoaded) {
            final profile = state.profile;

            // Initialize controllers with profile values
            if (!isEditing) {
              nameController.text = profile['name'] ?? '';
              phoneController.text = profile['phone'] ?? '';
              emailController.text = profile['email'] ?? '';
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Information:'),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isEditing = !isEditing;
                            });

                            if (isEditing) {
                              Future.microtask(() {
                                nameFocusNode.requestFocus();
                              });
                            }
                          },
                          child: Text(isEditing ? 'Save' : 'Edit Profile'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildEditableItem(
                      'Guardian Name',
                      nameController,
                      focusNode: nameFocusNode,
                    ),
                    const SizedBox(height: 12),
                    _buildEditableItem('Phone', phoneController),
                    const SizedBox(height: 12),
                    _buildEditableItem('Email', emailController),
                  ],
                ),
              ),
            );
          } else if (state is ProfileError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEditableItem(
    String label,
    TextEditingController controller, {
    FocusNode? focusNode,
  }) {
    return isEditing
        ? AppTextField(
            controller: controller,
            label: label,
            focusNode: focusNode,
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.lightBackground,
                ),
                child: Text(
                  controller.text,
                  style: AppTextStyles.bodyRegular.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
  }
}
