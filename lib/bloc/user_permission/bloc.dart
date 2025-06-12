import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/api/models/device.dart';
import 'package:smart_home_app/api/models/device_group.dart';
import 'package:smart_home_app/api/models/permission.dart';
import 'package:smart_home_app/bloc/user_permission/event.dart';
import 'package:smart_home_app/bloc/user_permission/state.dart';

class UserPermissionBloc extends Bloc<UserPermissionEvent, UserPermissionState> {
  final ApiClient _apiClient;
  
  UserPermissionBloc(this._apiClient) : super(UserPermissionInitial()) {
    on<LoadUserPermission>(_onLoadUserPermission);
    on<UpdateUserPermissionOnDevice>(_onUpdateUserPermissionOnDevice);
    on<UpdateUserPermissionOnDeviceGroup>(_onUpdateUserPermissionOnDeviceGroup);
  }
  
  Future<void> _onLoadUserPermission(
    LoadUserPermission event,
    Emitter<UserPermissionState> emit,
  ) async {
    emit(UserPermissionLoading());
    try {
      final userId = num.parse(event.userId);

      final responseDeviceList = await _apiClient.getDevices();
      final responseDeviceGroupList = await _apiClient.getDeviceGroups();
      final responseDevicePermissionList = await _apiClient.getUserPermissionOnDevices(userId);
      final responseDeviceGroupPermissionList = await _apiClient.getUserPermissionOnDeviceGroups(userId);

      final devices = List<Device>.from(responseDeviceList.data['data']
        .map(
          (deviceJson) => Device(
            id: deviceJson['id']?.toString() ?? 'Unknown',
            name: deviceJson['name'] ?? 'Unknown',
            type: DeviceType.fromString(deviceJson['device_type']),
            isOnline: (deviceJson['status'] ?? 'offline') == 'online',
          )
        )
        .toList()
        .where((t) => t != null)
      );

      final deviceGroups = List<DeviceGroup>.from(responseDeviceGroupList.data['results']
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

      final devicePermissions = List<DevicePermission>.from(responseDevicePermissionList.data['data']
        .map(
          (deviceJson) => DevicePermission(
            deviceId: deviceJson['id'],
            level: PermissionLevel.fromString(deviceJson['permission'])
          )
        )
        .toList()
        .where((t) => (t != null) && (t.level != PermissionLevel.none))
      );

      final deviceGroupPermissions = List<DeviceGroupPermission>.from(responseDeviceGroupPermissionList.data['data']
        .map(
          (deviceJson) => DeviceGroupPermission(
            deviceGroupId: deviceJson['id'],
            level: PermissionLevel.fromString(deviceJson['permission'])
          )
        )
        .toList()
        .where((t) => (t != null) && (t.level != PermissionLevel.none))
      );
      
      final permissionDeviceIds = devicePermissions.map((e) => e.deviceId);
      final permissionDeviceGroupIds = deviceGroupPermissions.map((e) => e.deviceGroupId);

      final permissionDevices = devices.where((d) => 
        permissionDeviceIds.contains(num.parse(d.id))).toList();
      final nonePermissionDevices = devices.where((user) => 
        !permissionDeviceIds.contains(num.parse(user.id))).toList();
      final permissionDeviceGroups = deviceGroups.where((d) => 
        permissionDeviceGroupIds.contains(num.parse(d.id))).toList();
      final nonePermissionDeviceGroups = deviceGroups.where((user) => 
        !permissionDeviceGroupIds.contains(num.parse(user.id))).toList();

      emit(UserPermissionLoaded(
        userId: event.userId,
        devicePermissions: devicePermissions,
        deviceGroupPermissions: deviceGroupPermissions,
        permissionDevices: permissionDevices,
        nonePermissionDevices: nonePermissionDevices,
        permissionDeviceGroups: permissionDeviceGroups,
        nonePermissionDeviceGroups: nonePermissionDeviceGroups,
      ));
    } catch (e) {
      emit(UserPermissionError('Failed to load user permission: $e'));
    }
  }
  
  Future<void> _onUpdateUserPermissionOnDevice(
    UpdateUserPermissionOnDevice event,
    Emitter<UserPermissionState> emit,
  ) async {
    final currentState = state;
    if (currentState is UserPermissionLoaded) {
      try {
        // 调用 API 更新权限记录
        await _apiClient.updateUserPermissionOnDevice(
          num.parse(currentState.userId),
          event.level,
          num.parse(event.deviceId)
        );

        // 刷新
        add(LoadUserPermission(currentState.userId));
      } catch (e) {
        emit(UserPermissionError('Failed to update user permission: $e'));
      }
    }
  }
  
  Future<void> _onUpdateUserPermissionOnDeviceGroup(
    UpdateUserPermissionOnDeviceGroup event,
    Emitter<UserPermissionState> emit,
  ) async {
    final currentState = state;
    if (currentState is UserPermissionLoaded) {
      try {
        // 调用 API 更新权限记录
        await _apiClient.updateUserPermissionOnDeviceGroup(
          num.parse(currentState.userId),
          event.level,
          num.parse(event.deviceGroupId)
        );
        
        // 刷新
        add(LoadUserPermission(currentState.userId));
      } catch (e) {
        emit(UserPermissionError('Failed to update user permission: $e'));
      }
    }
  }
}