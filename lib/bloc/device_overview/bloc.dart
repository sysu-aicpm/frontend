import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/api/models/device.dart';
import 'package:smart_home_app/bloc/device_overview/event.dart';
import 'package:smart_home_app/bloc/device_overview/state.dart';

class DeviceOverviewBloc extends Bloc<DeviceOverviewEvent, DeviceOverviewState> {
  final ApiClient _apiClient;

  DeviceOverviewBloc(this._apiClient) : super(DeviceOverviewInitial()) {
    on<LoadDevicesOverview>(_onLoadDevices);
  }

  Future<void> _onLoadDevices(
    LoadDevicesOverview event,
    Emitter<DeviceOverviewState> emit,
  ) async {
    emit(DeviceOverviewInProgress());
    try {
      final response = await _apiClient.getDevices();
      final devices = List<Device>.from(response.data['data']
        .map(
          (deviceJson) => Device(
            id: deviceJson['id']?.toString() ?? 'Unknown',
            name: deviceJson['name'] ?? 'Unknown',
            type: DeviceType.fromString(deviceJson['device_type']),
            isOnline: (deviceJson['status'] ?? 'offline') == 'online',
          )
        )
        .toList()
        .where((device) => device != null)
      );
      
      emit(DeviceOverviewSuccess(devices: devices));
    } catch (e) {
      emit(DeviceOverviewFailure(error: 'Failed to load devices. $e'));
    }
  }
} 