import 'package:equatable/equatable.dart';
import 'package:smart_home_app/api/models/device.dart';
import 'package:smart_home_app/api/models/device_group.dart';

abstract class DeviceGroupState extends Equatable {
  const DeviceGroupState();

  @override
  List<Object> get props => [];
}

class DeviceGroupInitial extends DeviceGroupState {}

class DeviceGroupLoading extends DeviceGroupState {}

class DeviceGroupLoaded extends DeviceGroupState {
  final DeviceGroup deviceGroup;
  final List<Device> groupDevices;
  final List<Device> availableDevices;
  
  const DeviceGroupLoaded({
    required this.deviceGroup,
    required this.groupDevices,
    required this.availableDevices,
  });

  @override
  List<Object> get props => [deviceGroup, groupDevices, availableDevices];
}

class DeviceGroupError extends DeviceGroupState {
  final String error;
  const DeviceGroupError(this.error);

  @override
  List<Object> get props => [error];
}