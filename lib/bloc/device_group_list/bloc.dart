import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/api/models/device_group.dart';
import 'package:smart_home_app/bloc/device_group_list/event.dart';
import 'package:smart_home_app/bloc/device_group_list/state.dart';

class DeviceGroupListBloc extends Bloc<DeviceGroupListEvent, DeviceGroupListState> {
  final ApiClient _apiClient;

  DeviceGroupListBloc(this._apiClient) : super(DeviceGroupListInitial()) {
    on<LoadDeviceGroupList>(_onLoadUsers);
    on<CreateDeviceGroup>(_onCreateDeviceGroup);
    on<RemoveDeviceGroup>(_onRemoveDeviceGroup);
  }

  Future<void> _onLoadUsers(
    LoadDeviceGroupList event,
    Emitter<DeviceGroupListState> emit,
  ) async {
    emit(DeviceGroupListInProgress());
    try {
      final response = await _apiClient.getDeviceGroups();
      final devices = List<DeviceGroup>.from(response.data['results']
        .map(
          (json) => DeviceGroup(
            id: json['id']?.toString() ?? 'Unknown',
            name: json['name'] ?? 'Unknown',
            description: json['description'] ?? 'Unknown',
            devices: List<num>.from(json['devices'])
          )
        )
        .toList()
        .where((t) => t != null)
      );
      
      emit(DeviceGroupListSuccess(deviceGroups: devices));
    } catch (e) {
      emit(DeviceGroupListFailure(error: 'Failed to load device groups. $e'));
    }
  }

  Future<void> _onCreateDeviceGroup(
    CreateDeviceGroup event,
    Emitter<DeviceGroupListState> emit,
  ) async {
    final currentState = state;
    if (currentState is DeviceGroupListSuccess) {
      try {
        // 调用 api 创建设备组
        await _apiClient.createDeviceGroup(
          event.name,
          event.description
        );
        
        // 刷新设备组列表
        add(LoadDeviceGroupList());
      } catch (e) {
        emit(DeviceGroupListFailure(error: 'Failed to create device group: $e'));
      }
    }
  }
  
  Future<void> _onRemoveDeviceGroup(
    RemoveDeviceGroup event,
    Emitter<DeviceGroupListState> emit,
  ) async {
    final currentState = state;
    if (currentState is DeviceGroupListSuccess) {
      try {
        await _apiClient.deleteDeviceGroup(
          num.parse(event.deviceGroupId)
        );
        
        // 刷新设备组列表
        add(LoadDeviceGroupList());
      } catch (e) {
        emit(DeviceGroupListFailure(error: 'Failed to delete device group: $e'));
      }
    }
  }
}