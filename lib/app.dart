import 'package:blithepay/core/services/session_timeout_manager.dart';
import 'package:blithepay/core/storage/auth_local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/navigation/routes.dart';
import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';
import 'core/theme/theme_cubit.dart';

final GoRouter appRouter = AppRouterConfig.createRouter();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp.router(
          title: 'BLITHE',
          scaffoldMessengerKey: scaffoldMessengerKey,
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: themeState.brightness == Brightness.dark
              ? ThemeMode.dark
              : ThemeMode.light,
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return SessionTimeoutListener(
              localDataSource: context.read<AppLocalDataSource>(),
              child: GestureDetector(
                onTap: () {
                  final currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  }
                },
                behavior: HitTestBehavior.translucent,
                child: child,
              ),
            );
          },
        );
      },
    );
  }
}
