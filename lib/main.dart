import 'package:blithepay/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
