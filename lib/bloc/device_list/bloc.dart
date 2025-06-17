import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/api/models/device.dart';
import 'package:smart_home_app/bloc/device_list/event.dart';
import 'package:smart_home_app/bloc/device_list/state.dart';

class DeviceListBloc extends Bloc<DeviceListEvent, DeviceListState> {
  final ApiClient _apiClient;
  List<NewDeviceData> _newDevices = [];

  DeviceListBloc(this._apiClient) : super(DeviceListInitial()) {
    on<LoadDeviceList>(_onLoadDeviceList);
    on<DeleteDevice>(_onDeleteDevice);
    on<SyncDevice>(_onSyncDevice);
    on<DiscoverNewDevice>(_onDiscoverNewDevice);
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

  Future<void> _onDiscoverNewDevice(
    DiscoverNewDevice event,
    Emitter<DeviceListState> emit,
  ) async {
    emit(DeviceListInProgress());
    try {
      final response = await _apiClient.discoverDevice();
      final datas = List<NewDeviceData>.from(response.data['data']
        .map(
          (deviceJson) => NewDeviceData(
            deviceIdentifier: deviceJson['device_identifier'] ?? 'Unknown',
            name: deviceJson['name'] ?? 'Unknown',
            ip: deviceJson['ip'],  // shouldn't be null
            port: deviceJson['port'],  // shouldn't be null
            deviceType: DeviceType.fromString(deviceJson['device_type']),
            status: deviceJson['status'] ?? 'Unknown',
            power: deviceJson['power'] ?? 0,
            ssdpLocation: deviceJson['ssdp_location'] ?? 'Unknown',
            ssdpNT: deviceJson['ssdp_nt'] ?? 'Unknown',
            ssdpUSN: deviceJson['ssdp_usn'] ?? 'Unknown',
            alreadyAdded: deviceJson['already_added'] ?? false,
          )
        )
        .toList()
        .where((d) => !d.alreadyAdded)
      );

      _newDevices = datas;
      
      emit(DiscoverNewDeviceSuccess(datas: datas, newDeviceAdded: false));
    } catch (e) {
      emit(DeviceListFailure(error: 'Failed to discover devices. $e'));
    }
  }

  Future<void> _onSyncDevice(
    SyncDevice event,
    Emitter<DeviceListState> emit,
  ) async {
    emit(DeviceListInProgress());
    try {
      final response = await _apiClient.syncDevice(event.data);
      if (!response.data['success']) {
        throw Exception(response.data['message']);
      }

      _newDevices.remove(event.data);
      emit(DiscoverNewDeviceSuccess(datas: _newDevices, newDeviceAdded: true));
    } catch (e) {
      emit(DeviceListFailure(error: 'Failed to add device. $e'));
    }
  }
} 