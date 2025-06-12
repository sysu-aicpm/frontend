import 'package:equatable/equatable.dart';

abstract class DeviceGroupListEvent extends Equatable {
  const DeviceGroupListEvent();

  @override
  List<Object> get props => [];
}

class LoadDeviceGroupList extends DeviceGroupListEvent {}

class CreateDeviceGroup extends DeviceGroupListEvent {
  final String name;
  final String? description;
  const CreateDeviceGroup(this.name, this.description);

  @override
  List<Object> get props => [name];
}

class RemoveDeviceGroup extends DeviceGroupListEvent {
  final String deviceGroupId;
  const RemoveDeviceGroup(this.deviceGroupId);

  @override
  List<Object> get props => [deviceGroupId];
}