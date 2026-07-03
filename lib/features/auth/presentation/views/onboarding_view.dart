import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/core/storage/auth_local_storage.dart';
import 'package:blithepay/shared/widgets/background/auth_flow_background.dart';
import 'package:blithepay/shared/widgets/web_page_view.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import 'package:blithepay/shared/widgets/buttons/secondary_outlined_button.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  late PageController _pageController;
  int _currentIndex = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      image: 'assets/images/onboarding_1.png',
      title: 'Secure School Payments',
      description: AppStrings.paySecurelyDesc,
    ),
    OnboardingPage(
      image: 'assets/images/onboarding_2.png',
      title: 'Unified Utility Payments',
      description: AppStrings.manageMultipleDesc,
    ),
    OnboardingPage(
      image: 'assets/images/onboarding_3.png',
      title: 'Transparency & Reminders',
      description: AppStrings.getRemindersDesc,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToCreateAccount() async {
    final appLocalDataSource = context.read<AppLocalDataSource>();
    await appLocalDataSource.setOnboardingCompleted();
    if (mounted) {
      context.go(AppRoutes.signup);
    }
  }

  void _goToLogin() async {
    final appLocalDataSource = context.read<AppLocalDataSource>();
    await appLocalDataSource.setOnboardingCompleted();
    if (mounted) {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AppScaffold(
      showBackButton: false,
      body: AuthBackgroundWrapper(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Skip Button
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextButton(
                    onPressed: _goToCreateAccount,
                    child: Text(
                      'Skip',
                      style: AppTextStyles.bodyRegular.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              // Page View (Hero Illustrations)
              Expanded(
                flex: 11,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentIndex = index),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Center(
                        child: Image.asset(
                          page.image,
                          fit: BoxFit.contain,
                          height: size.height * 0.35,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Text & Controls Bottom Sheet Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pill Page Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _currentIndex == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentIndex == index
                                ? AppColors.primary
                                : AppColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Title
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _pages[_currentIndex].title,
                        key: ValueKey<int>(_currentIndex),
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description
                    SizedBox(
                      height: 64, // Keep height static to prevent layout shift
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _pages[_currentIndex].description,
                          key: ValueKey<int>(_currentIndex),
                          style: AppTextStyles.bodyRegular.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Primary Button (Next or Get Started)
                    PrimaryButton(
                      label: _currentIndex == _pages.length - 1
                          ? AppStrings.getStarted
                          : 'Next',
                      onPressed: () {
                        if (_currentIndex < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOutCubic,
                          );
                        } else {
                          _goToCreateAccount();
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // Log In Button
                    SizedBox(
                      width: double.infinity,
                      child: SecondaryOutlinedButton(
                        label: AppStrings.logIn,
                        height: 48,
                        onPressed: _goToLogin,
                        borderColor: AppColors.primary,
                        textStyle: AppTextStyles.button.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Interactive Terms & Conditions + Privacy Policy Link
                    Text.rich(
                      TextSpan(
                        text: AppStrings.byRegisteringYourAccount,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          TextSpan(
                            text: AppStrings.termsAndConditions,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const WebPageView(
                                      url: 'https://www.blithepay.com/terms',
                                      title: 'Terms & Conditions',
                                    ),
                                  ),
                                );
                              },
                          ),
                          TextSpan(
                            text: ' and ',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextSpan(
                            text: AppStrings.privacyPolicy,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const WebPageView(
                                      url: 'https://www.blithepay.com/privacy',
                                      title: 'Privacy Policy',
                                    ),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String image;
  final String title;
  final String description;

  OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
  });
}

