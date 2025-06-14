import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/api/models/user.dart';
import 'package:smart_home_app/bloc/auth/event.dart';
import 'package:smart_home_app/bloc/auth/state.dart';
import 'package:smart_home_app/config/env.dart';
import 'package:smart_home_app/flutter_chat_desktop/providers/settings_providers.dart';
import 'package:smart_home_app/utils/secure_storage.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;
  final WidgetRef? _ref;

  AuthBloc(this._apiClient, this._secureStorage, [this._ref]) : super(AuthInitial()) {
    on<AuthenticationStatusChecked>(_onAuthenticationStatusChecked);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAuthenticationStatusChecked(
    AuthenticationStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final token = await _secureStorage.getToken();
    if (token != null) {
      try {
        final userInfoResponse = await _apiClient.getUserInfo();
        final json = userInfoResponse.data['data'];
        final user = User(
          id: json['id'].toString(),
          email: json['email'] ?? 'Unknown',
          username: json['username'] ?? 'Unknown',
          firstname: json['first_name'] ?? 'Unknown',
          lastname: json['last_name'] ?? 'Unknown',
          isStaff: json['is_staff'] ?? false,
        );

        final pyScripName = 'mcp_server.py';
        _ref?.read(settingsServiceProvider)
          .addMcpServer(
            "aicpm",
            "python",
            "$pyScripName --backend ${Env.apiUrl} --token $token",
            {}
          );

        emit(Authenticated(user: user));
      } catch (e) {
        // Failed to get user info, token might be expired
        await _secureStorage.deleteToken();
        emit(Unauthenticated());
      }
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // First, get the token
      final loginResponse = await _apiClient.login(event.email, event.password);
      final String token = loginResponse.data['access'];
      await _secureStorage.saveToken(token);
      // TODO: save refresh TOKEN

      // Then, get user info with the new token
      final userInfoResponse = await _apiClient.getUserInfo();
      final json = userInfoResponse.data['data'];
      final user = User(
        id: json['id'].toString(),
        email: json['email'] ?? 'Unknown',
        username: json['username'] ?? 'Unknown',
        firstname: json['first_name'] ?? 'Unknown',
        lastname: json['last_name'] ?? 'Unknown',
        isStaff: json['is_staff'] ?? false,
      );

      final pyScripName = 'mcp_server.py';
      _ref?.read(settingsServiceProvider)
        .addMcpServer(
          "aicpm",
          "python",
          "$pyScripName --backend ${Env.apiUrl} --token $token",
          {}
        );

      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthFailure(error: 'Login Failed. Please check your credentials. $e'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await _secureStorage.deleteToken();
    emit(Unauthenticated());
  }
} 