import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/api/models/device.dart';
import 'package:smart_home_app/api/models/device_group.dart';
import 'package:smart_home_app/api/models/permission.dart';
import 'package:smart_home_app/bloc/user_group_permission/event.dart';
import 'package:smart_home_app/bloc/user_group_permission/state.dart';

class UserGroupPermissionBloc extends Bloc<UserGroupPermissionEvent, UserGroupPermissionState> {
  final ApiClient _apiClient;
  
  UserGroupPermissionBloc(this._apiClient) : super(UserGroupPermissionInitial()) {
    on<LoadUserGroupPermission>(_onLoadUserGroupPermission);
    on<UpdateUserGroupPermissionOnDevice>(_onUpdateUserGroupPermissionOnDevice);
    on<UpdateUserGroupPermissionOnDeviceGroup>(_onUpdateUserGroupPermissionOnDeviceGroup);
  }
  
  Future<void> _onLoadUserGroupPermission(
    LoadUserGroupPermission event,
    Emitter<UserGroupPermissionState> emit,
  ) async {
    emit(UserGroupPermissionLoading());
    try {
      final userGroupId = num.parse(event.userGroupId);

      final responseDeviceList = await _apiClient.getDevices();
      final responseDeviceGroupList = await _apiClient.getDeviceGroups();
      final responseDevicePermissionList = await _apiClient.getUserGroupPermissionOnDevices(userGroupId);
      final responseDeviceGroupPermissionList = await _apiClient.getUserGroupPermissionOnDeviceGroups(userGroupId);

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
      final nonePermissionDevices = devices.where((userGroup) => 
        !permissionDeviceIds.contains(num.parse(userGroup.id))).toList();
      final permissionDeviceGroups = deviceGroups.where((d) => 
        permissionDeviceGroupIds.contains(num.parse(d.id))).toList();
      final nonePermissionDeviceGroups = deviceGroups.where((userGroup) => 
        !permissionDeviceGroupIds.contains(num.parse(userGroup.id))).toList();

      emit(UserGroupPermissionLoaded(
        userGroupId: event.userGroupId,
        devicePermissions: devicePermissions,
        deviceGroupPermissions: deviceGroupPermissions,
        permissionDevices: permissionDevices,
        nonePermissionDevices: nonePermissionDevices,
        permissionDeviceGroups: permissionDeviceGroups,
        nonePermissionDeviceGroups: nonePermissionDeviceGroups,
      ));
    } catch (e) {
      emit(UserGroupPermissionError('Failed to load user group permission: $e'));
    }
  }
  
  Future<void> _onUpdateUserGroupPermissionOnDevice(
    UpdateUserGroupPermissionOnDevice event,
    Emitter<UserGroupPermissionState> emit,
  ) async {
    final currentState = state;
    if (currentState is UserGroupPermissionLoaded) {
      try {
        // 调用 API 更新权限记录
        await _apiClient.updateUserGroupPermissionOnDevice(
          num.parse(currentState.userGroupId),
          event.level,
          num.parse(event.deviceId)
        );

        // 刷新
        add(LoadUserGroupPermission(currentState.userGroupId));
      } catch (e) {
        emit(UserGroupPermissionError('Failed to update user group permission: $e'));
      }
    }
  }
  
  Future<void> _onUpdateUserGroupPermissionOnDeviceGroup(
    UpdateUserGroupPermissionOnDeviceGroup event,
    Emitter<UserGroupPermissionState> emit,
  ) async {
    final currentState = state;
    if (currentState is UserGroupPermissionLoaded) {
      try {
        // 调用 API 更新权限记录
        await _apiClient.updateUserGroupPermissionOnDeviceGroup(
          num.parse(currentState.userGroupId),
          event.level,
          num.parse(event.deviceGroupId)
        );
        
        // 刷新
        add(LoadUserGroupPermission(currentState.userGroupId));
      } catch (e) {
        emit(UserGroupPermissionError('Failed to update user group permission: $e'));
      }
    }
  }
}