import 'package:smart_home_app/api/models/permission.dart';

abstract class UserPermissionEvent {}

class LoadUserPermission extends UserPermissionEvent {
  final String userId;
  LoadUserPermission(this.userId);
}

class UpdateUserPermissionOnDevice extends UserPermissionEvent {
  final String deviceId;
  final PermissionLevel level;

  UpdateUserPermissionOnDevice(this.deviceId, this.level);
}

class UpdateUserPermissionOnDeviceGroup extends UserPermissionEvent {
  final String deviceGroupId;
  final PermissionLevel level;

  UpdateUserPermissionOnDeviceGroup(this.deviceGroupId, this.level);
}