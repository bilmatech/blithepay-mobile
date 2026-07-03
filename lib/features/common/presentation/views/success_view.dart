import 'dart:async';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/background/auth_flow_background.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';

class SuccessView extends StatefulWidget {
  final String title;
  final String message;
  final String buttonLabel;
  final String nextRoute;
  final Object? nextExtra;
  final bool useAuthBackground;

  const SuccessView({
    super.key,
    required this.title,
    required this.message,
    this.buttonLabel = 'My Dashboard',
    required this.nextRoute,
    this.nextExtra,
    this.useAuthBackground = false,
  });

  @override
  State<SuccessView> createState() => _SuccessViewState();
}

class _SuccessViewState extends State<SuccessView> {
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();
    // Start auto-redirect timer (3 seconds)
    _redirectTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        context.go(widget.nextRoute, extra: widget.nextExtra);
      }
    });
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  void _navigateNow() {
    _redirectTimer?.cancel();
    context.go(widget.nextRoute, extra: widget.nextExtra);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: AuthBackgroundWrapper(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/success.png',
                        width: 64,
                        height: 64,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.title,
                    style: AppTextStyles.headingLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.message,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    label: widget.buttonLabel,
                    onPressed: _navigateNow,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
