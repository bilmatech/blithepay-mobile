import 'app.dart';
import 'package:flutter/material.dart';
import 'package:blithepay/providers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blithepay/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:blithepay/services/local_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    MultiRepositoryProvider(
      providers: AppProviders.repositories(),
      child: MultiBlocProvider(
        providers: AppProviders.blocs(),
        child: const MyApp(),
      ),
    ),
  );
}
