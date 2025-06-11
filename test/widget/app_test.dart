import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/api/models/device.dart';
import 'package:smart_home_app/api/models/user.dart';
import 'package:smart_home_app/bloc/auth/bloc.dart';
import 'package:smart_home_app/bloc/auth/event.dart';
import 'package:smart_home_app/bloc/auth/state.dart';
import 'package:smart_home_app/bloc/device_overview/bloc.dart';
import 'package:smart_home_app/bloc/device_overview/event.dart';
import 'package:smart_home_app/bloc/device_overview/state.dart';
import 'package:smart_home_app/main.dart';
import 'package:smart_home_app/pages/home_page.dart';
import 'package:smart_home_app/pages/login_page.dart';

// Mock BLoCs
class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}
class MockDeviceBloc extends MockBloc<DeviceOverviewEvent, DeviceOverviewState> implements DeviceOverviewBloc {}

// Mock ApiClient
class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockDeviceBloc mockDeviceBloc;
  late MockApiClient mockApiClient;
  
  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockDeviceBloc = MockDeviceBloc();
    mockApiClient = MockApiClient();

    registerFallbackValue(mockApiClient);
    
    // Provide a default state for auth
    when(() => mockAuthBloc.state).thenReturn(Unauthenticated());
    registerFallbackValue(const LoginRequested(email: '', password: ''));
  });

  const tUser = User(
    id: '1',
    username: 'test',
    firstname: 'a',
    lastname: 'b',
    isStaff: false,
  );
  final tDevices = [
    const Device(id: '1', name: 'Smart Lamp', type: DeviceType.light, isOnline: true),
  ];

  Widget createTestableWidget(Widget child) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        BlocProvider<DeviceOverviewBloc>.value(value: mockDeviceBloc),
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
          child: const MaterialApp(home: MyApp()),
        ),
      );

      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('displays HomePage when state is Authenticated', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const Authenticated(user: tUser));
      when(() => mockDeviceBloc.state).thenReturn(DeviceOverviewInitial());

      await tester.pumpWidget(createTestableWidget(const MyApp()));
      
      await tester.pump();

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('tapping login button dispatches LoginRequested event', (tester) async {
      await tester.pumpWidget(createTestableWidget(const LoginPage()));

      await tester.enterText(find.byKey(const ValueKey('username_field')), 'user');
      await tester.enterText(find.byKey(const ValueKey('password_field')), 'pass');
      await tester.tap(find.byType(ElevatedButton));
      
      verify(() => mockAuthBloc.add(const LoginRequested(email: 'user', password: 'pass'))).called(1);
    });
  });

  group('HomePage Widget Tests', () {
    testWidgets('shows loading indicator when devices are loading', (tester) async {
      when(() => mockDeviceBloc.state).thenReturn(DeviceOverviewInProgress());

      await tester.pumpWidget(createTestableWidget(const HomePage(isStaff: false)));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays a list of devices on success', (tester) async {
      when(() => mockDeviceBloc.state).thenReturn(DeviceOverviewSuccess(devices: tDevices));

      await tester.pumpWidget(createTestableWidget(const HomePage(isStaff: false)));

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Smart Lamp'), findsOneWidget);
    });

    testWidgets('displays error message on failure', (tester) async {
      when(() => mockDeviceBloc.state).thenReturn(const DeviceOverviewFailure(error: 'Failed'));

      await tester.pumpWidget(createTestableWidget(const HomePage(isStaff: false)));

      expect(find.text('Failed'), findsOneWidget);
    });
  });
} 