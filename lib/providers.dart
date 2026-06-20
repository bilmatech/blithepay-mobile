import 'package:blithepay/core/network/dio_client.dart';
import 'package:blithepay/core/storage/auth_local_storage.dart';
import 'package:blithepay/core/theme/theme_cubit.dart';
import 'package:blithepay/features/auth/data/repositories/auth_repository.dart';
import 'package:blithepay/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:blithepay/features/fees/data/repositories/fees_repository.dart';
import 'package:blithepay/features/fees/presentation/bloc/fees_bloc.dart';
import 'package:blithepay/features/fees/presentation/bloc/payment_bloc/payment_bloc.dart';
import 'package:blithepay/features/notifications/data/repositories/notifications_repository.dart';
import 'package:blithepay/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:blithepay/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:blithepay/features/services/data/repositories/service_repository.dart';
import 'package:blithepay/features/schools/data/repositories/schools_repository.dart';
import 'package:blithepay/features/schools/presentation/bloc/schools_bloc.dart';
import 'package:blithepay/features/services/presentation/bloc/services_cubit/services_cubit.dart';
import 'package:blithepay/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:blithepay/features/students/data/repositories/students_repository.dart';
import 'package:blithepay/features/students/presentation/bloc/invoice_bloc.dart/invoice_bloc.dart';
import 'package:blithepay/features/students/presentation/bloc/students_bloc.dart';
import 'package:blithepay/features/students/presentation/bloc/students_event.dart';
import 'package:blithepay/features/students/presentation/bloc/transaction_bloc.dart/transaction_bloc.dart';
import 'package:blithepay/features/support/presentation/bloc/support_bloc.dart';
import 'package:blithepay/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:blithepay/features/wallet/data/repositories/wallet_repository.dart';
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
      RepositoryProvider<FlutterSecureStorage>(
        create: (_) => const FlutterSecureStorage(),
      ),

      RepositoryProvider<AppLocalDataSourceImpl>(
        create: (context) =>
            AppLocalDataSourceImpl(context.read<FlutterSecureStorage>()),
      ),

      RepositoryProvider<DioClient>(
        create: (context) => DioClient(context.read<AppLocalDataSourceImpl>()),
      ),
      RepositoryProvider<AuthRepository>(create: (_) => authRepository),
      RepositoryProvider<WalletRepositoryInterface>(
        create: (context) =>
            WalletRepository(dioClient: context.read<DioClient>()),
      ),
      // Add other repositories here
      RepositoryProvider<StudentsRepository>(
        create: (context) =>
            StudentsRepositoryImpl(dioClient: context.read<DioClient>()),
      ),
      RepositoryProvider<SchoolsRepository>(
        create: (context) =>
            SchoolsRepositoryImpl(dioClient: context.read<DioClient>()),
      ),
      RepositoryProvider<NotificationsRepository>(
        create: (_) => NotificationsRepositoryImpl(),
      ),
      RepositoryProvider<FeesRepository>(
        create: (context) =>
            FeesRepositoryImpl(dioClient: context.read<DioClient>()),
      ),
      RepositoryProvider<ServiceRepository>(
        create: (context) =>
            ServiceRepositoryImpl(dioClient: context.read<DioClient>()),
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
        create: (context) => DashboardBloc(
          localDataSource: context.read<AppLocalDataSourceImpl>(),
          walletRepository: context.read<WalletRepositoryInterface>(),
        ),
      ),
      BlocProvider<WalletBloc>(
        create: (context) => WalletBloc(
          walletRepository: context.read<WalletRepositoryInterface>(),
        ),
      ),
      BlocProvider<WalletTransactionBloc>(
        create: (context) => WalletTransactionBloc(
          walletRepository: context.read<WalletRepositoryInterface>(),
        ),
      ),

      BlocProvider<SupportBloc>(create: (_) => SupportBloc()),
      BlocProvider<StudentsBloc>(
        create: (context) =>
            StudentsBloc(repository: context.read<StudentsRepository>())
              ..add(const GetLinkedStudentsEvent(page: 1)),
      ),
      BlocProvider<InvoiceBloc>(
        create: (context) =>
            InvoiceBloc(repository: context.read<StudentsRepository>()),
      ),
      BlocProvider<ServicesCubit>(
        create: (context) =>
            ServicesCubit(serviceRepository: context.read<ServiceRepository>()),
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
      BlocProvider<FeesBloc>(
        create: (context) =>
            FeesBloc(repository: context.read<FeesRepository>()),
      ),
      BlocProvider<StudentTransactionsBloc>(
        create: (context) => StudentTransactionsBloc(
          repository: context.read<StudentsRepository>(),
        ),
      ),
      BlocProvider<PaymentBloc>(
        create: (context) =>
            PaymentBloc(repository: context.read<FeesRepository>()),
      ),
      BlocProvider<ProfileBloc>(
        create: (context) => ProfileBloc(
          context.read<AppLocalDataSourceImpl>(),
          context.read<AuthRepository>(),
        ),
      ),
    ];
  }
}
