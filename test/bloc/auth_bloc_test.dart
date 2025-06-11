import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/api/models/user.dart';
import 'package:smart_home_app/bloc/auth/bloc.dart';
import 'package:smart_home_app/bloc/auth/event.dart';
import 'package:smart_home_app/bloc/auth/state.dart';
import 'package:smart_home_app/utils/secure_storage.dart';

// Mocks
class MockApiClient extends Mock implements ApiClient {}
class MockSecureStorage extends Mock implements SecureStorage {}

void main() {
  late AuthBloc authBloc;
  late MockApiClient mockApiClient;
  late MockSecureStorage mockSecureStorage;

  setUp(() {
    mockApiClient = MockApiClient();
    mockSecureStorage = MockSecureStorage();
    authBloc = AuthBloc(mockApiClient, mockSecureStorage);
  });

  tearDown(() {
    authBloc.close();
  });

  const tUser = User(
    id: '1',
    email: '114@514.com',
    username: 'test',
    firstname: 'a',
    lastname: 'b',
    isStaff: false,
  );
  final tLoginResponse = Response(
    requestOptions: RequestOptions(path: ''),
    data: {'access': 'fake_access_token'},
  );
  final tUserInfoResponse = Response(
    requestOptions: RequestOptions(path: ''),
    data: {'id': '1', 'username': 'test'},
  );

  test('initial state is AuthInitial', () {
    expect(authBloc.state, AuthInitial());
  });

  group('LoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when login and getUserInfo are successful',
      build: () {
        when(() => mockApiClient.login('test', 'password')).thenAnswer((_) async => tLoginResponse);
        when(() => mockSecureStorage.saveToken(any())).thenAnswer((_) async {});
        when(() => mockApiClient.getUserInfo()).thenAnswer((_) async => tUserInfoResponse);
        return authBloc;
      },
      act: (bloc) => bloc.add(const LoginRequested(email: 'test', password: 'password')),
      expect: () => [
        AuthLoading(),
        const Authenticated(user: tUser),
      ],
      verify: (_) {
        verify(() => mockSecureStorage.saveToken('fake_access_token')).called(1);
        verify(() => mockApiClient.getUserInfo()).called(1);
      }
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when login fails',
      build: () {
        when(() => mockApiClient.login(any(), any())).thenThrow(Exception('Login Failed'));
        return authBloc;
      },
      act: (bloc) => bloc.add(const LoginRequested(email: 'test', password: 'password')),
      expect: () => [
        AuthLoading(),
        const AuthFailure(error: 'Login Failed. Please check your credentials.'),
      ],
    );
  });

  group('AuthenticationStatusChecked', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when token exists and getUserInfo is successful',
      build: () {
        when(() => mockSecureStorage.getToken()).thenAnswer((_) async => 'fake_access_token');
        when(() => mockApiClient.getUserInfo()).thenAnswer((_) async => tUserInfoResponse);
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthenticationStatusChecked()),
      expect: () => [
        AuthLoading(),
        const Authenticated(user: tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when getUserInfo fails',
      build: () {
        when(() => mockSecureStorage.getToken()).thenAnswer((_) async => 'fake_access_token');
        when(() => mockApiClient.getUserInfo()).thenThrow(Exception('API Error'));
        when(() => mockSecureStorage.deleteToken()).thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthenticationStatusChecked()),
      expect: () => [
        AuthLoading(),
        Unauthenticated(),
      ],
    );
  });
} 