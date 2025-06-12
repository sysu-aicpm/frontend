import 'package:equatable/equatable.dart';
import 'package:smart_home_app/api/models/device.dart';
import 'package:smart_home_app/api/models/device_group.dart';
import 'package:smart_home_app/api/models/permission.dart';

abstract class UserGroupPermissionState extends Equatable {
  const UserGroupPermissionState();

  @override
  List<Object> get props => [];
}

class UserGroupPermissionInitial extends UserGroupPermissionState {}

class UserGroupPermissionLoading extends UserGroupPermissionState {}

class UserGroupPermissionLoaded extends UserGroupPermissionState {
  final String userGroupId;
  final List<DevicePermission> devicePermissions;
  final List<DeviceGroupPermission> deviceGroupPermissions;
  final List<Device> permissionDevices;
  final List<Device> nonePermissionDevices;  // 没有任何权限的设备
  final List<DeviceGroup> permissionDeviceGroups;
  final List<DeviceGroup> nonePermissionDeviceGroups;  // 没有任何权限记录的设备组
  
  const UserGroupPermissionLoaded({
    required this.userGroupId,
    required this.devicePermissions,
    required this.deviceGroupPermissions,
    required this.permissionDevices,
    required this.nonePermissionDevices,
    required this.permissionDeviceGroups,
    required this.nonePermissionDeviceGroups,
  });

  @override
  List<Object> get props => [devicePermissions, deviceGroupPermissions];
}

class UserGroupPermissionError extends UserGroupPermissionState {
  final String error;
  const UserGroupPermissionError(this.error);

  @override
  List<Object> get props => [error];
}