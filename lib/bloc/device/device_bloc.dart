import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/api/models/device.dart';
import 'package:smart_home_app/bloc/device/device_event.dart';
import 'package:smart_home_app/bloc/device/device_state.dart';

class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  final ApiClient _apiClient;

  DeviceBloc(this._apiClient) : super(DeviceInitial()) {
    on<LoadDevices>(_onLoadDevices);
  }

  Future<void> _onLoadDevices(
    LoadDevices event,
    Emitter<DeviceState> emit,
  ) async {
    emit(DeviceLoadInProgress());
    try {
      final response = await _apiClient.getDevices();
      final devices = List<Device>.from(response.data['results']
        .map(
          (deviceJson) => Device(
            id: deviceJson['id']?.toString() ?? 'Unknown ID',
            name: deviceJson['name'] ?? 'Unknown Name',
            type: deviceJson['device_type'] ?? 'Unknown Type',
            isOnline: (deviceJson['status'] ?? 'offline') == 'online',
          )
        )
        .toList()
        .where((device) => device != null)
      );
      
      emit(DeviceLoadSuccess(devices: devices));
    } catch (e) {
      emit(const DeviceLoadFailure(error: 'Failed to load devices.'));
    }
  }
} 