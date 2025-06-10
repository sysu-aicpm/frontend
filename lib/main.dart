import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/bloc/app_bloc_observer.dart';
import 'package:smart_home_app/bloc/auth/bloc.dart';
import 'package:smart_home_app/bloc/auth/event.dart';
import 'package:smart_home_app/bloc/auth/state.dart';
import 'package:smart_home_app/pages/home_page.dart';
import 'package:smart_home_app/pages/login_page.dart';
import 'package:smart_home_app/utils/secure_storage.dart';

void main() {
  Bloc.observer = AppBlocObserver();
  runApp(
    RepositoryProvider(
      create: (context) => SecureStorage(),
      child: RepositoryProvider(
        create: (context) => ApiClient(context.read<SecureStorage>()),
        child: BlocProvider(
          create: (context) => AuthBloc(
            context.read<ApiClient>(),
            context.read<SecureStorage>(),
          )..add(AuthenticationStatusChecked()),
          child: const MyApp(),
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return const HomePage();
          }
          return const LoginPage();
        },
      ),
    );
  }
}
