import 'package:equatable/equatable.dart';
import 'package:smart_home_app/api/models/device.dart';
import 'package:smart_home_app/api/models/device_group.dart';
import 'package:smart_home_app/api/models/permission.dart';

abstract class UserPermissionState extends Equatable {
  const UserPermissionState();

  @override
  List<Object> get props => [];
}

class UserPermissionInitial extends UserPermissionState {}

class UserPermissionLoading extends UserPermissionState {}

class UserPermissionLoaded extends UserPermissionState {
  final String userId;
  final List<DevicePermission> devicePermissions;
  final List<DeviceGroupPermission> deviceGroupPermissions;
  final List<Device> permissionDevices;
  final List<Device> nonePermissionDevices;  // 没有任何权限的设备
  final List<DeviceGroup> permissionDeviceGroups;
  final List<DeviceGroup> nonePermissionDeviceGroups;  // 没有任何权限记录的设备组
  
  const UserPermissionLoaded({
    required this.userId,
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

class UserPermissionError extends UserPermissionState {
  final String error;
  const UserPermissionError(this.error);

  @override
  List<Object> get props => [error];
}