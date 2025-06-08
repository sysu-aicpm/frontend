import 'package:equatable/equatable.dart';

abstract class PermissionEvent extends Equatable {
  const PermissionEvent();

  @override
  List<Object> get props => [];
}

class LoadPermissions extends PermissionEvent {
  final String deviceId;

  const LoadPermissions(this.deviceId);

  @override
  List<Object> get props => [deviceId];
}

class ShareDevice extends PermissionEvent {
  final String deviceId;
  final String userId;
  final String role;

  const ShareDevice({required this.deviceId, required this.userId, required this.role});

  @override
  List<Object> get props => [deviceId, userId, role];
}

class RevokePermission extends PermissionEvent {
  final String permissionId;

  const RevokePermission(this.permissionId);

  @override
  List<Object> get props => [permissionId];
} 