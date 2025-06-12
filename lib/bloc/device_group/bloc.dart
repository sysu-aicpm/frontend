import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/api/models/device.dart';
import 'package:smart_home_app/api/models/device_group.dart';
import 'package:smart_home_app/bloc/device_group/event.dart';
import 'package:smart_home_app/bloc/device_group/state.dart';

class DeviceGroupBloc extends Bloc<DeviceGroupEvent, DeviceGroupState> {
  final ApiClient _apiClient;
  
  DeviceGroupBloc(this._apiClient) : super(DeviceGroupInitial()) {
    on<LoadDeviceGroupDetail>(_onLoadDeviceGroupDetail);
    on<AddDeviceToGroup>(_onAddDeviceToGroup);
    on<RemoveDeviceFromGroup>(_onRemoveDeviceFromGroup);
  }
  
  Future<void> _onLoadDeviceGroupDetail(
    LoadDeviceGroupDetail event,
    Emitter<DeviceGroupState> emit,
  ) async {
    emit(DeviceGroupLoading());
    try {
      // 获取所有设备
      final allDevicesResponse = await _apiClient.getDevices();
      final allDevices = List<Device>.from(allDevicesResponse.data['data']
        .map((deviceJson) => Device(
          id: deviceJson['id']?.toString() ?? 'Unknown',
          name: deviceJson['name'] ?? 'Unknown',
          type: DeviceType.fromString(deviceJson['device_type']),
          isOnline: (deviceJson['status'] ?? 'offline') == 'online',
        ))
        .toList());
      
      // 筛选出组内设备和可用设备
      final groupDevices = allDevices.where((device) => 
        event.deviceGroup.devices.contains(num.parse(device.id))).toList();
      final availableDevices = allDevices.where((device) => 
        !event.deviceGroup.devices.contains(num.parse(device.id))).toList();
      
      emit(DeviceGroupLoaded(
        deviceGroup: event.deviceGroup,
        groupDevices: groupDevices,
        availableDevices: availableDevices,
      ));
    } catch (e) {
      emit(DeviceGroupError('Failed to load device group details: $e'));
    }
  }
  
  Future<void> _onAddDeviceToGroup(
    AddDeviceToGroup event,
    Emitter<DeviceGroupState> emit,
  ) async {
    final currentState = state;
    if (currentState is DeviceGroupLoaded) {
      try {
        // 调用 API 添加设备到组
        await _apiClient.addDeviceToDeviceGroup(
          num.parse(currentState.deviceGroup.id), 
          num.parse(event.deviceId)
        );
        
        // 重新加载数据
        final updatedGroup = DeviceGroup(
          id: currentState.deviceGroup.id,
          name: currentState.deviceGroup.name,
          description: currentState.deviceGroup.description,
          devices: [...currentState.deviceGroup.devices, num.parse(event.deviceId)],
        );
        
        add(LoadDeviceGroupDetail(updatedGroup));
      } catch (e) {
        emit(DeviceGroupError('Failed to add device to group: $e'));
      }
    }
  }
  
  Future<void> _onRemoveDeviceFromGroup(
    RemoveDeviceFromGroup event,
    Emitter<DeviceGroupState> emit,
  ) async {
    final currentState = state;
    if (currentState is DeviceGroupLoaded) {
      try {
        // 调用 API 从组中移除设备
        await _apiClient.rmDeviceFromDeviceGroup(
          num.parse(currentState.deviceGroup.id), 
          num.parse(event.deviceId)
        );
        
        // 重新加载数据
        final updatedGroup = DeviceGroup(
          id: currentState.deviceGroup.id,
          name: currentState.deviceGroup.name,
          description: currentState.deviceGroup.description,
          devices: currentState.deviceGroup.devices
            .where((id) => id != num.parse(event.deviceId))
            .toList(),
        );
        
        add(LoadDeviceGroupDetail(updatedGroup));
      } catch (e) {
        emit(DeviceGroupError('Failed to remove device from group: $e'));
      }
    }
  }
}