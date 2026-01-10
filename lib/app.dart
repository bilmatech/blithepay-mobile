import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/navigation/app_routes.dart';
import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/views/login_view.dart';
import 'features/auth/presentation/views/signup_view.dart';
import 'features/auth/presentation/views/forgot_password_view.dart';
import 'features/auth/presentation/views/verify_otp_view.dart';
import 'features/auth/presentation/views/reset_password_view.dart';
import 'features/auth/presentation/views/password_changed_view.dart';
import 'features/auth/presentation/views/onboarding_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(
          create: (_) => AuthBloc(authRepository: AuthRepository()),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'BÜTHE',
            theme: buildLightTheme(),
            darkTheme: buildDarkTheme(),
            themeMode: themeState.brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
            routerConfig: _buildRouter(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  GoRouter _buildRouter() {
    return GoRouter(
      initialLocation: AppRoutes.onboarding,
      routes: [
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (_, __) => const OnboardingView(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (_, __) => const LoginView(),
        ),
        GoRoute(
          path: AppRoutes.signup,
          builder: (_, __) => const SignupView(),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (_, __) => const ForgotPasswordView(),
        ),
        GoRoute(
          path: AppRoutes.verifyOtp,
          builder: (context, state) {
            final email = state.extra as String? ?? '';
            return VerifyOtpView(email: email);
          },
        ),
        GoRoute(
          path: AppRoutes.resetPassword,
          builder: (context, state) {
            final email = state.extra as String? ?? '';
            return ResetPasswordView(email: email);
          },
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (_, __) => const PasswordChangedView(), // Placeholder for home
        ),
      ],
    );
  }
}
