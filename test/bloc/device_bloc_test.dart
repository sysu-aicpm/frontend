import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/api/models/device.dart';
import 'package:smart_home_app/bloc/device/device_bloc.dart';
import 'package:smart_home_app/bloc/device/device_event.dart';
import 'package:smart_home_app/bloc/device/device_state.dart';

// Mocks
class MockApiClient extends Mock implements ApiClient {}
class MockDioResponse extends Mock implements Response {}

void main() {
  late DeviceBloc deviceBloc;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    deviceBloc = DeviceBloc(mockApiClient);
  });

  tearDown(() {
    deviceBloc.close();
  });

  final tDevices = [
    const Device(id: '1', name: 'Smart Lamp', type: 'Light', isOnline: true),
    const Device(id: '2', name: 'Smart Thermostat', type: 'Thermostat', isOnline: false),
  ];

  final tResponse = Response(
    requestOptions: RequestOptions(path: '/devices'),
    data: [
      {'id': '1', 'name': 'Smart Lamp', 'type': 'Light', 'isOnline': true},
      {'id': '2', 'name': 'Smart Thermostat', 'type': 'Thermostat', 'isOnline': false},
    ],
  );

  test('initial state is DeviceInitial', () {
    expect(deviceBloc.state, DeviceInitial());
  });

  group('LoadDevices', () {
    blocTest<DeviceBloc, DeviceState>(
      'emits [DeviceLoadInProgress, DeviceLoadSuccess] when getDevices is successful',
      build: () {
        when(() => mockApiClient.getDevices()).thenAnswer((_) async => tResponse);
        return deviceBloc;
      },
      act: (bloc) => bloc.add(LoadDevices()),
      expect: () => [
        DeviceLoadInProgress(),
        DeviceLoadSuccess(devices: tDevices),
      ],
      verify: (_) {
        verify(() => mockApiClient.getDevices()).called(1);
      },
    );

    blocTest<DeviceBloc, DeviceState>(
      'emits [DeviceLoadInProgress, DeviceLoadFailure] when getDevices fails',
      build: () {
        when(() => mockApiClient.getDevices()).thenThrow(Exception('Failed to load devices'));
        return deviceBloc;
      },
      act: (bloc) => bloc.add(LoadDevices()),
      expect: () => [
        DeviceLoadInProgress(),
        const DeviceLoadFailure(error: 'Failed to load devices.'),
      ],
      verify: (_) {
        verify(() => mockApiClient.getDevices()).called(1);
      },
    );
  });
} 