import 'app.dart';
import 'package:flutter/material.dart';
import 'package:blithepay/providers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blithepay/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:blithepay/core/services/local_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await MediaStore.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final notificationService = NotificationService();
  await notificationService.init();

  await GoogleSignIn.instance.initialize(
    serverClientId: '313986921733-tk50b3nbm29hgo2oraptfvkjske5pm7o.apps.googleusercontent.com',
  );

  runApp(
    MultiRepositoryProvider(
      providers: AppProviders.repositories(),
      child: MultiBlocProvider(providers: AppProviders.blocs(), child: const MyApp()),
    ),
  );
}
