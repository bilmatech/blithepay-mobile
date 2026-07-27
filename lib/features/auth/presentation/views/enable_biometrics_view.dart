import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blithepay/core/navigation/index.dart';
import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/core/storage/auth_local_storage.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:blithepay/core/services/biometric_crypto_service.dart';
import 'package:blithepay/features/auth/data/repositories/auth_repository.dart';
import 'package:blithepay/shared/widgets/buttons/secondary_outlined_button.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_event.dart';

class EnableBiometricsView extends StatefulWidget {
  final String? email;

  const EnableBiometricsView({super.key, this.email});

  @override
  State<EnableBiometricsView> createState() => _EnableBiometricsViewState();
}

class _EnableBiometricsViewState extends State<EnableBiometricsView> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkStatusAndRedirect();
  }

  Future<void> _checkStatusAndRedirect() async {
    final localDataSource = context.read<AppLocalDataSource>();
    final isEnabled = await localDataSource.isBiometricsEnabled();
    final dontShow = await localDataSource.getDontShowBiometricPrompt();

    if (isEnabled || dontShow) {
      await _proceedToDashboard();
    }
  }

  Future<void> _proceedToDashboard() async {
    if (!mounted) return;
    context.read<DashboardBloc>().add(const FetchDashboardData());
    context.go(AppRoutes.home);
  }

  Future<void> _enableBiometrics() async {
    if (_isLoading) return;

    final localDataSource = context.read<AppLocalDataSource>();
    final authRepository = context.read<AuthRepository>();

    String? userEmail = widget.email;
    if (userEmail == null || userEmail.isEmpty) {
      final session = await localDataSource.getSession();
      userEmail = session!.user!.email;
    }

    if (userEmail == null || userEmail.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cannot enable biometric login without user email.")),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Generate key pair natively in secure hardware
      final publicKey = await BiometricCryptoService.generateKeyPair();
      if (publicKey == null || publicKey.isEmpty) {
        throw Exception("Biometric key pair generation cancelled or failed.");
      }

      // 2. Get/create device ID
      final deviceId = await localDataSource.getOrCreateDeviceId();

      // 3. Enroll device on backend API
      await authRepository.enrollBiometric(
        email: userEmail,
        deviceId: deviceId,
        publicKey: publicKey,
      );

      // 4. Save settings locally
      await localDataSource.setBiometricsEnabled(true);
      await localDataSource.setBiometricEmail(userEmail);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Biometric Login enabled successfully!")));
        await _proceedToDashboard();
      }
    } catch (e) {
      String errorMsg = "Enrollment failed.";
      if (e is PlatformException) {
        errorMsg = e.message ?? errorMsg;
      } else {
        errorMsg = "Enrollment failed: ${e.toString().replaceAll('Exception: ', '')}";
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _skip() async {
    await _proceedToDashboard();
  }

  Future<void> _dontShowAgain() async {
    final localDataSource = context.read<AppLocalDataSource>();
    await localDataSource.setDontShowBiometricPrompt(true);
    await _proceedToDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showBackButton: false,
      body: SafeArea(
        child: Container(
          color: AppColors.white,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.fingerprint_rounded, size: 56, color: AppColors.primary),
              ),
              const SizedBox(height: 32),
              const Text(
                'Enable Biometric Login',
                style: AppTextStyles.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Speed up your sign-in process with Face ID or Fingerprint authentication for quick and secure access to BlithePay.',
                style: AppTextStyles.bodyRegular,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Enable Right Now',
                isLoading: _isLoading,
                onPressed: _enableBiometrics,
              ),
              const SizedBox(height: 12),
              SecondaryOutlinedButton(label: 'Skip for Now', onPressed: _isLoading ? null : _skip),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _isLoading ? null : _dontShowAgain,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Don't show this again",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
