import 'package:blithepay/core/network/dio_client.dart';
import 'package:blithepay/core/storage/auth_local_storage.dart';
import 'package:blithepay/core/theme/theme_cubit.dart';
import 'package:blithepay/features/auth/data/repositories/auth_repository.dart';
import 'package:blithepay/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:blithepay/features/fees/presentation/bloc/fees_bloc.dart';
import 'package:blithepay/features/notifications/data/repositories/notifications_repository.dart';
import 'package:blithepay/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:blithepay/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:blithepay/features/schools/data/repositories/schools_repository.dart';
import 'package:blithepay/features/schools/presentation/bloc/schools_bloc.dart';
import 'package:blithepay/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:blithepay/features/students/data/repositories/students_repository.dart';
import 'package:blithepay/features/students/presentation/bloc/students_bloc.dart';
import 'package:blithepay/features/support/presentation/bloc/support_bloc.dart';
import 'package:blithepay/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppProviders {
  // This method returns all RepositoryProviders
  static List<RepositoryProvider> repositories() {
    const secureStorage = FlutterSecureStorage();

    final authLocalDataSource = AppLocalDataSourceImpl(secureStorage);
    final dioClient = DioClient(authLocalDataSource);
    final authRepository = AuthRepository(
      dioClient: dioClient,
      localDataSource: authLocalDataSource,
    );

    return [
      RepositoryProvider<AppLocalDataSource>(
        create: (_) => authLocalDataSource,
      ),
      RepositoryProvider<DioClient>(create: (_) => dioClient),
      RepositoryProvider<AuthRepository>(create: (_) => authRepository),
      // Add other repositories here
      RepositoryProvider<StudentsRepository>(
        create: (_) => StudentsRepositoryImpl(),
      ),
      RepositoryProvider<SchoolsRepository>(
        create: (_) => SchoolsRepositoryImpl(),
      ),
      RepositoryProvider<NotificationsRepository>(
        create: (_) => NotificationsRepositoryImpl(),
      ),
    ];
  }

  // This method returns all BlocProviders
  static List<BlocProvider> blocs() {
    return [
      BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
      BlocProvider<SplashBloc>(
        create: (context) =>
            SplashBloc(authRepository: context.read<AuthRepository>()),
      ),
      BlocProvider<AuthBloc>(
        create: (context) =>
            AuthBloc(authRepository: context.read<AuthRepository>()),
      ),
      BlocProvider<DashboardBloc>(
        create: (_) =>
            DashboardBloc(AppLocalDataSourceImpl(const FlutterSecureStorage())),
      ),
      BlocProvider<FeesBloc>(create: (_) => FeesBloc()),
      BlocProvider<WalletBloc>(create: (_) => WalletBloc()),
      BlocProvider<SupportBloc>(create: (_) => SupportBloc()),
      BlocProvider<StudentsBloc>(
        create: (context) =>
            StudentsBloc(repository: context.read<StudentsRepository>()),
      ),
      BlocProvider<SchoolsBloc>(
        create: (context) =>
            SchoolsBloc(repository: context.read<SchoolsRepository>()),
      ),
      BlocProvider<NotificationsBloc>(
        create: (context) => NotificationsBloc(
          repository: context.read<NotificationsRepository>(),
        ),
      ),
      BlocProvider<ProfileBloc>(create: (_) => ProfileBloc()),
    ];
  }
}
