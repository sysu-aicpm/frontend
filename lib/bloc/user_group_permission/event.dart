import 'package:smart_home_app/api/models/permission.dart';

abstract class UserGroupPermissionEvent {}

class LoadUserGroupPermission extends UserGroupPermissionEvent {
  final String userGroupId;
  LoadUserGroupPermission(this.userGroupId);
}

class UpdateUserGroupPermissionOnDevice extends UserGroupPermissionEvent {
  final String deviceId;
  final PermissionLevel level;

  UpdateUserGroupPermissionOnDevice(this.deviceId, this.level);
}

class UpdateUserGroupPermissionOnDeviceGroup extends UserGroupPermissionEvent {
  final String deviceGroupId;
  final PermissionLevel level;

  UpdateUserGroupPermissionOnDeviceGroup(this.deviceGroupId, this.level);
}