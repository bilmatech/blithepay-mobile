import 'package:blithepay/core/storage/auth_local_storage.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';

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
      title: AppStrings.paySecurely,
      description: AppStrings.paySecurelyDesc,
    ),
    OnboardingPage(
      image: 'assets/images/onboarding_2.png',
      title: AppStrings.manageMultiple,
      description: AppStrings.manageMultipleDesc,
    ),
    OnboardingPage(
      image: 'assets/images/onboarding_3.png',
      title: AppStrings.getReminders,
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

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Only the image changes here
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Stack(
                    children: [
                      // Image
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.asset(
                          page.image,
                          fit: BoxFit.contain,
                          width: double.infinity,
                        ),
                      ),

                      // Top-left clickable area
                      Positioned(
                        top: 40,
                        right: 40,
                        child: GestureDetector(
                          onTap: _goToCreateAccount,
                          child: Container(
                            width: 80,
                            height: 40,
                            color:
                                Colors.transparent, // invisible tappable area
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Fixed section: dots, title, description, button
            Container(
              padding: const EdgeInsets.only(right: 24, left: 24, bottom: 24),
              child: Column(
                children: [
                  // Dots indicator
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentIndex == index ? 12 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(_pages[_currentIndex].title, style: AppTextStyles.h2),
                  const SizedBox(height: 12),
                  Text(
                    _pages[_currentIndex].description,
                    style: AppTextStyles.bodyRegular,
                  ),
                  const SizedBox(height: 40),
                  PrimaryButton(
                    label: _currentIndex == _pages.length - 1
                        ? AppStrings.createAccount
                        : AppStrings.next,
                    onPressed: () {
                      if (_currentIndex == _pages.length - 1) {
                        _goToCreateAccount();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
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
