import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/api/models/user.dart';
import 'package:smart_home_app/bloc/auth/event.dart';
import 'package:smart_home_app/bloc/auth/state.dart';
import 'package:smart_home_app/utils/secure_storage.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;

  AuthBloc(this._apiClient, this._secureStorage) : super(AuthInitial()) {
    on<AuthenticationStatusChecked>(_onAuthenticationStatusChecked);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<RegisterRequested>(_onRegisterRequested);
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
        final user = User(
          id: userInfoResponse.data['data']['id'].toString(),
          username: userInfoResponse.data['data']['username'],
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

      // Then, get user info with the new token
      final userInfoResponse = await _apiClient.getUserInfo();      
      final user = User(
        id: userInfoResponse.data['data']['id'].toString(),
        username: userInfoResponse.data['data']['username'],
      );
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthFailure(error: 'Login Failed. Please check your credentials. $e'));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (event.password != event.confirmPassword) {
      emit(const AuthFailure(error: 'Passwords do not match.'));
      emit(AuthInitial());
      return;
    }
    emit(AuthLoading());
    try {
      await _apiClient.register(event.email, event.password);
      emit(RegistrationSuccessful());
    } catch (e) {
      emit(const AuthFailure(error: 'Registration Failed. The email might already be in use.'));
      emit(AuthInitial());
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