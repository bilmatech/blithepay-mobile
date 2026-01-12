import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/navigation/routes.dart';
import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/fees/presentation/bloc/fees_bloc.dart';
import 'features/wallet/presentation/bloc/wallet_bloc.dart';
import 'features/support/presentation/bloc/support_bloc.dart';
import 'features/students/data/repositories/students_repository.dart';
import 'features/students/presentation/bloc/students_bloc.dart';
import 'features/schools/data/repositories/schools_repository.dart';
import 'features/schools/presentation/bloc/schools_bloc.dart';
import 'features/notifications/data/repositories/notifications_repository.dart';
import 'features/notifications/presentation/bloc/notifications_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';

final GoRouter appRouter = AppRouterConfig.createRouter();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => AuthBloc(authRepository: AuthRepository())),
        BlocProvider(create: (_) => DashboardBloc()),
        BlocProvider(create: (_) => FeesBloc()),
        BlocProvider(create: (_) => WalletBloc()),
        BlocProvider(create: (_) => SupportBloc()),
        BlocProvider(
          create: (_) => StudentsBloc(repository: StudentsRepositoryImpl()),
        ),
        BlocProvider(
          create: (_) => SchoolsBloc(repository: SchoolsRepositoryImpl()),
        ),
        BlocProvider(
          create: (_) =>
              NotificationsBloc(repository: NotificationsRepositoryImpl()),
        ),
        BlocProvider(create: (_) => ProfileBloc()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'BÜTHE',
            theme: buildLightTheme(),
            darkTheme: buildDarkTheme(),
            themeMode: themeState.brightness == Brightness.dark
                ? ThemeMode.dark
                : ThemeMode.light,
            routerConfig: appRouter,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
