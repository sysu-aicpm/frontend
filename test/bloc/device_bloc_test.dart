import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/api/models/device.dart';
import 'package:smart_home_app/bloc/device_overview/bloc.dart';
import 'package:smart_home_app/bloc/device_overview/event.dart';
import 'package:smart_home_app/bloc/device_overview/state.dart';

// Mocks
class MockApiClient extends Mock implements ApiClient {}
class MockDioResponse extends Mock implements Response {}

void main() {
  late DeviceOverviewBloc deviceBloc;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    deviceBloc = DeviceOverviewBloc(mockApiClient);
  });

  tearDown(() {
    deviceBloc.close();
  });

  final tDevices = [
    const Device(id: '1', name: 'Smart Lamp', type: DeviceType.light, isOnline: true),
    const Device(id: '2', name: 'Smart Thermostat', type: DeviceType.air_conditioner, isOnline: false),
  ];

  final tResponse = Response(
    requestOptions: RequestOptions(path: '/devices'),
    data: [
      {'id': '1', 'name': 'Smart Lamp', 'type': 'light', 'isOnline': true},
      {'id': '2', 'name': 'Smart Thermostat', 'type': 'air_conditioner', 'isOnline': false},
    ],
  );

  test('initial state is DeviceInitial', () {
    expect(deviceBloc.state, DeviceOverviewInitial());
  });

  group('LoadDevices', () {
    blocTest<DeviceOverviewBloc, DeviceOverviewState>(
      'emits [DeviceLoadInProgress, DeviceLoadSuccess] when getDevices is successful',
      build: () {
        when(() => mockApiClient.getDevices()).thenAnswer((_) async => tResponse);
        return deviceBloc;
      },
      act: (bloc) => bloc.add(LoadDevicesOverview()),
      expect: () => [
        DeviceOverviewInProgress(),
        DeviceOverviewSuccess(devices: tDevices),
      ],
      verify: (_) {
        verify(() => mockApiClient.getDevices()).called(1);
      },
    );

    blocTest<DeviceOverviewBloc, DeviceOverviewState>(
      'emits [DeviceLoadInProgress, DeviceLoadFailure] when getDevices fails',
      build: () {
        when(() => mockApiClient.getDevices()).thenThrow(Exception('Failed to load devices'));
        return deviceBloc;
      },
      act: (bloc) => bloc.add(LoadDevicesOverview()),
      expect: () => [
        DeviceOverviewInProgress(),
        const DeviceOverviewFailure(error: 'Failed to load devices.'),
      ],
      verify: (_) {
        verify(() => mockApiClient.getDevices()).called(1);
      },
    );
  });
} 