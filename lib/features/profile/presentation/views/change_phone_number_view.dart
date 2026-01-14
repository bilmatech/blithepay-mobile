import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';

class ChangePhoneNumberView extends StatefulWidget {
  const ChangePhoneNumberView({super.key});

  @override
  State<ChangePhoneNumberView> createState() => _ChangePhoneNumberViewState();
}

class _ChangePhoneNumberViewState extends State<ChangePhoneNumberView> {
  final _currentPhoneController = TextEditingController();
  final _newPhoneController = TextEditingController();
  final _otpControllers = List.generate(4, (_) => TextEditingController());

  bool _showOTP = false;

  @override
  void dispose() {
    _currentPhoneController.dispose();
    _newPhoneController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Change Phone Number'), elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Change Phone Number', style: AppTextStyles.headingLarge),
              const SizedBox(height: 24),
              _buildPhoneField(
                label: 'Current Number',
                controller: _currentPhoneController,
              ),
              const SizedBox(height: 20),
              _buildPhoneField(
                label: 'New Number',
                controller: _newPhoneController,
              ),
              if (_showOTP) ...[
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Receive OTP',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Enter OTP',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    4,
                    (index) => SizedBox(
                      width: 60,
                      child: TextField(
                        controller: _otpControllers[index],
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Change Number',
                onPressed: () {
                  
                  // setState(() {
                  //   _showOTP = !_showOTP;
                  // });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('🇳🇬'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppTextField(
                controller: controller,
                hint: '+234',
                label: '',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
