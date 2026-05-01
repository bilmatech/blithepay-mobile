import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:blithepay/shared/widgets/index.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/core/storage/auth_local_storage.dart';
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
      image: 'assets/images/Icon.png',
      title: AppStrings.paySecurely,
      description: AppStrings.paySecurelyDesc,
    ),
    OnboardingPage(
      image: 'assets/images/Icon.png',
      title: AppStrings.manageMultiple,
      description: AppStrings.manageMultipleDesc,
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
    return AppScaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/onboarding.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Pattern overlay
            Container(color: Colors.black.withOpacity(0.2)),
            // Glass effect
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
              child: Container(color: Colors.black.withOpacity(0.1)),
            ),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) =>
                          setState(() => _currentIndex = index),
                      itemCount: _pages.length,
                      itemBuilder: (context, index) {
                        final page = _pages[index];
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: SizedBox(
                              width: double.infinity,
                              height: 280,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 10,
                                    sigmaY: 10,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.white.withOpacity(0.15),
                                      border: Border.all(
                                        color: AppColors.white.withOpacity(0.2),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(28),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(28),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(height: 10),
                                        Container(
                                          width: 84,
                                          height: 84,
                                          decoration: BoxDecoration(
                                            color: AppColors.white,
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                          ),
                                          child: Center(
                                            child: Image.asset(
                                              page.image,
                                              width: 48,
                                              height: 48,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 28),
                                        Text(
                                          page.title,
                                          style: AppTextStyles.h3.copyWith(
                                            color: AppColors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          page.description,
                                          style: AppTextStyles.bodyRegularBlack
                                              .copyWith(
                                                color: AppColors.white
                                                    .withOpacity(0.9),
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      bottom: 20,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _pages.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentIndex == index
                                    ? AppColors.white
                                    : AppColors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        PrimaryButton(
                          label: AppStrings.getStarted,
                          onPressed: _goToCreateAccount,
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: SecondaryOutlinedButton(
                            label: AppStrings.logIn,
                            onPressed: _goToLogin,
                            borderColor: AppColors.white,
                            textStyle: AppTextStyles.button.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text.rich(
                          TextSpan(
                            text: AppStrings.byRegisteringYourAccount,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.white.withOpacity(0.8),
                            ),
                            children: [
                              const TextSpan(
                                text: AppStrings.termsAndConditions,
                                style: AppTextStyles.link,
                              ),
                              TextSpan(
                                text: ' and ',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.white.withOpacity(0.8),
                                ),
                              ),
                              const TextSpan(
                                text: AppStrings.privacyPolicy,
                                style: AppTextStyles.link,
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
