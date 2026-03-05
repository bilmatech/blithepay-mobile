import 'package:blithepay/core/storage/auth_local_storage.dart';
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
  bool isEditing = false;

  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  late final FocusNode nameFocusNode;

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
          }

          if (state is ProfileLoaded) {
            final profile = state.profile;

            // Apply API profile ONCE
            if (!_controllersInitialized) {
              nameController.text = profile['name'] ?? nameController.text;
              phoneController.text = profile['phone'] ?? phoneController.text;
              emailController.text = profile['email'] ?? emailController.text;
              _controllersInitialized = true;
            }

            return SingleChildScrollView(
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
                            Future.microtask(
                              () => nameFocusNode.requestFocus(),
                            );
                          } else {
                            // SAVE here (name + phone only)
                            // context.read<ProfileBloc>().add(
                            //   UpdateProfileEvent(
                            //     name: nameController.text.trim(),
                            //     phone: phoneController.text.trim(),
                            //   ),
                            // );
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

                  _buildEditableItem(
                    'Email',
                    emailController,
                    enabled: false, 
                  ),
                ],
              ),
            );
          }

          if (state is ProfileError) {
            return Center(child: Text(state.message));
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
    bool enabled = true,
  }) {
    return isEditing && enabled
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
  }
}
