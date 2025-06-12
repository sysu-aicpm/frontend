import 'package:equatable/equatable.dart';

enum PermissionLevel {
  none,
  visible,
  usable,
  configurable,
  monitorable,
  manageable;

  static PermissionLevel fromString(String? value) {
    return PermissionLevel.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PermissionLevel.none,
    );
  }
}

class DevicePermission extends Equatable {
  final num deviceId;
  final PermissionLevel level;

  const DevicePermission({
    required this.deviceId,
    required this.level
  });

  @override
  List<Object> get props => [deviceId, level];
}

class DeviceGroupPermission extends Equatable {
  final num deviceGroupId;
  final PermissionLevel level;

  const DeviceGroupPermission({
    required this.deviceGroupId,
    required this.level
  });

  @override
  List<Object> get props => [deviceGroupId, level];
}