import 'package:equatable/equatable.dart';
import 'package:smart_home_app/api/models/device_group.dart';

abstract class DeviceGroupEvent extends Equatable {
  const DeviceGroupEvent();

  @override
  List<Object> get props => [];
}

class LoadDeviceGroupDetail extends DeviceGroupEvent {
  final DeviceGroup deviceGroup;
  const LoadDeviceGroupDetail(this.deviceGroup);

  @override
  List<Object> get props => [deviceGroup];
}

class AddDeviceToGroup extends DeviceGroupEvent {
  final String deviceId;
  const AddDeviceToGroup(this.deviceId);

  @override
  List<Object> get props => [deviceId];
}

class RemoveDeviceFromGroup extends DeviceGroupEvent {
  final String deviceId;
  const RemoveDeviceFromGroup(this.deviceId);

  @override
  List<Object> get props => [deviceId];
}