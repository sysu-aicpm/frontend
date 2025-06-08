import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/api/models/device.dart';
import 'package:smart_home_app/api/models/permission.dart';
import 'package:smart_home_app/api/models/user.dart';
import 'package:smart_home_app/bloc/auth/auth_bloc.dart';
import 'package:smart_home_app/bloc/auth/auth_event.dart';
import 'package:smart_home_app/bloc/auth/auth_state.dart';
import 'package:smart_home_app/bloc/device/device_bloc.dart';
import 'package:smart_home_app/bloc/device/device_event.dart';
import 'package:smart_home_app/bloc/device/device_state.dart';
import 'package:smart_home_app/bloc/permission/permission_bloc.dart';
import 'package:smart_home_app/bloc/permission/permission_event.dart';
import 'package:smart_home_app/bloc/permission/permission_state.dart';
import 'package:smart_home_app/main.dart';
import 'package:smart_home_app/pages/device_details_page.dart';
import 'package:smart_home_app/pages/home_page.dart';
import 'package:smart_home_app/pages/login_page.dart';
import 'package:smart_home_app/pages/share_device_dialog.dart';

// Mock BLoCs
class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}
class MockDeviceBloc extends MockBloc<DeviceEvent, DeviceState> implements DeviceBloc {}
class MockPermissionBloc extends MockBloc<PermissionEvent, PermissionState> implements PermissionBloc {}

// Mock ApiClient
class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockDeviceBloc mockDeviceBloc;
  late MockPermissionBloc mockPermissionBloc;
  late MockApiClient mockApiClient;
  
  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockDeviceBloc = MockDeviceBloc();
    mockPermissionBloc = MockPermissionBloc();
    mockApiClient = MockApiClient();

    registerFallbackValue(mockApiClient);

    when(() => mockApiClient.searchUsers(any())).thenAnswer((_) async => Response(requestOptions: RequestOptions(path: ''), data: []));
    
    // Provide a default state for auth
    when(() => mockAuthBloc.state).thenReturn(Unauthenticated());
    registerFallbackValue(const LoginRequested(username: '', password: ''));
  });

  const tUser = User(id: '1', username: 'test');
  final tDevices = [
    const Device(id: '1', name: 'Smart Lamp', type: 'Light', isOnline: true),
  ];
  final tPermissions = [
    const UserPermission(id: 'p1', userId: 'user2', username: 'bob', permissionLevel: PermissionLevel.usable),
  ];

  Widget createTestableWidget(Widget child) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        BlocProvider<DeviceBloc>.value(value: mockDeviceBloc),
        BlocProvider<PermissionBloc>.value(value: mockPermissionBloc),
      ],
      child: MaterialApp(home: child),
    );
  }

  group('App Navigation and UI Tests', () {
    testWidgets('displays LoginPage when state is Unauthenticated', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(Unauthenticated());

      await tester.pumpWidget(
        BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const MaterialApp(home: AppNavigator()),
        ),
      );

      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('displays HomePage when state is Authenticated', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const Authenticated(user: tUser));
      when(() => mockDeviceBloc.state).thenReturn(DeviceInitial());

      await tester.pumpWidget(createTestableWidget(const AppNavigator()));
      
      await tester.pump();

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('tapping login button dispatches LoginRequested event', (tester) async {
      await tester.pumpWidget(createTestableWidget(const LoginPage()));

      await tester.enterText(find.byKey(const ValueKey('username_field')), 'user');
      await tester.enterText(find.byKey(const ValueKey('password_field')), 'pass');
      await tester.tap(find.byType(ElevatedButton));
      
      verify(() => mockAuthBloc.add(const LoginRequested(username: 'user', password: 'pass'))).called(1);
    });
  });

  group('HomePage Widget Tests', () {
    testWidgets('shows loading indicator when devices are loading', (tester) async {
      when(() => mockDeviceBloc.state).thenReturn(DeviceLoadInProgress());

      await tester.pumpWidget(createTestableWidget(const HomePage()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays a list of devices on success', (tester) async {
      when(() => mockDeviceBloc.state).thenReturn(DeviceLoadSuccess(devices: tDevices));

      await tester.pumpWidget(createTestableWidget(const HomePage()));

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Smart Lamp'), findsOneWidget);
    });

    testWidgets('displays error message on failure', (tester) async {
      when(() => mockDeviceBloc.state).thenReturn(const DeviceLoadFailure(error: 'Failed'));

      await tester.pumpWidget(createTestableWidget(const HomePage()));

      expect(find.text('Failed'), findsOneWidget);
    });
  });

  group('DeviceDetailsPage Widget Tests', () {
    const tDevice = Device(id: 'd1', name: 'Test Device', type: 'Light', isOnline: true);

    testWidgets('shows loading indicator and then displays permissions', (tester) async {
      when(() => mockPermissionBloc.state).thenReturn(PermissionLoadInProgress());
      await tester.pumpWidget(createTestableWidget(const DeviceDetailsPage(device: tDevice)));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      whenListen(mockPermissionBloc, Stream.fromIterable([PermissionLoadSuccess(tPermissions)]), initialState: PermissionLoadInProgress());
      await tester.pump(); 

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('bob'), findsOneWidget);
      expect(find.text('Role: usable'), findsOneWidget);
    });

    testWidgets('tapping share button opens ShareDeviceDialog', (tester) async {
      when(() => mockPermissionBloc.state).thenReturn(const PermissionLoadSuccess([]));
      await tester.pumpWidget(createTestableWidget(const DeviceDetailsPage(device: tDevice)));
      
      await tester.tap(find.byIcon(Icons.share));
      await tester.pumpAndSettle();

      expect(find.byType(ShareDeviceDialog), findsOneWidget);
    });

    testWidgets('tapping delete on a permission shows confirmation and dispatches event', (tester) async {
      when(() => mockPermissionBloc.state).thenReturn(PermissionLoadSuccess(tPermissions));
      await tester.pumpWidget(createTestableWidget(const DeviceDetailsPage(device: tDevice)));

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Are you sure you want to revoke permission from bob?'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Revoke'));
      await tester.pumpAndSettle();

      verify(() => mockPermissionBloc.add(const RevokePermission('p1'))).called(1);
      verify(() => mockPermissionBloc.add(const LoadPermissions('d1'))).called(1);
    });
  });
} 