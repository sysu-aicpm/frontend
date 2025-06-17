import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/api/models/device.dart';
import 'package:smart_home_app/bloc/device_list/event.dart';
import 'package:smart_home_app/bloc/device_list/state.dart';

class DeviceListBloc extends Bloc<DeviceListEvent, DeviceListState> {
  final ApiClient _apiClient;

  DeviceListBloc(this._apiClient) : super(DeviceListInitial()) {
    on<LoadDeviceList>(_onLoadDeviceList);
    on<DeleteDevice>(_onDeleteDevice);
  }

  Future<void> _onDeleteDevice(
    DeleteDevice event,
    Emitter<DeviceListState> emit,
  ) async {
    try {
      await _apiClient.deleteDevice(event.deviceId);
      add(LoadDeviceList()); // Refresh the list
    } catch (e) {
      // Optionally, handle specific delete errors
      emit(DeviceListFailure(error: 'Failed to delete device. $e'));
      add(LoadDeviceList()); // Still refresh list on failure to get latest state
    }
  }

  Future<void> _onLoadDeviceList(
    LoadDeviceList event,
    Emitter<DeviceListState> emit,
  ) async {
    emit(DeviceListInProgress());
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
      
      emit(DeviceListSuccess(devices: devices));
    } catch (e) {
      emit(DeviceListFailure(error: 'Failed to load devices. $e'));
    }
  }
} 