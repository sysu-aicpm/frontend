import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/bloc/auth/bloc.dart';
import 'package:smart_home_app/bloc/auth/event.dart';
import 'package:smart_home_app/bloc/auth/state.dart';
import 'package:smart_home_app/pages/home_page.dart';
import 'package:smart_home_app/pages/login_page.dart';
import 'package:smart_home_app/utils/secure_storage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create instances of the dependencies
    final SecureStorage secureStorage = SecureStorage();
    final ApiClient apiClient = ApiClient(secureStorage);

    return RepositoryProvider.value(
      value: apiClient,
      child: BlocProvider(
        create: (context) => AuthBloc(
          context.read<ApiClient>(),
          secureStorage,
        )..add(AuthenticationStatusChecked()),
        child: MaterialApp(
          title: 'Smart Home App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const AppNavigator(),
        ),
      ),
    );
  }
}

class AppNavigator extends StatelessWidget {
  const AppNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return HomePage(isStaff: state.user.isStaff);
        }
        if (state is Unauthenticated || state is AuthFailure) {
          return const LoginPage();
        }
        // Show a loading screen while checking auth status
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
