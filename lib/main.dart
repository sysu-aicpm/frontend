import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/bloc/auth/bloc.dart';
import 'package:smart_home_app/bloc/auth/event.dart';
import 'package:smart_home_app/bloc/auth/state.dart';
import 'package:smart_home_app/flutter_chat_desktop/domains/settings/data/settings_repository_impl.dart';
import 'package:smart_home_app/flutter_chat_desktop/providers/settings_providers.dart';
import 'package:smart_home_app/pages/home_page.dart';
import 'package:smart_home_app/pages/login_page.dart';
import 'package:smart_home_app/utils/secure_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final initialSettingsRepo = SettingsRepositoryImpl(prefs);
  final initialApiKey = await initialSettingsRepo.getApiKey();
  final initialServerList = await initialSettingsRepo.getMcpServerList();
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        settingsRepositoryProvider.overrideWith(
          (ref) => SettingsRepositoryImpl(ref.watch(sharedPreferencesProvider)),
        ),
        apiKeyProvider.overrideWith((ref) => initialApiKey),
        mcpServerListProvider.overrideWith((ref) => initialServerList),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Create instances of the dependencies
    final SecureStorage secureStorage = SecureStorage();
    final ApiClient apiClient = ApiClient(secureStorage);

    return RepositoryProvider.value(
      value: apiClient,
      child: BlocProvider(
        create: (context) => AuthBloc(
          context.read<ApiClient>(),
          secureStorage,
          ref
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
        if (state is Unauthenticated || state is AuthFailure || state is RegistrationSuccessful) {
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
