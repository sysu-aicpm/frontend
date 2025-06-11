import 'package:equatable/equatable.dart';
import 'package:smart_home_app/api/models/device_group.dart';

abstract class DeviceGroupListState extends Equatable {
  const DeviceGroupListState();

  @override
  List<Object> get props => [];
}

class DeviceGroupListInitial extends DeviceGroupListState {}

class DeviceGroupListInProgress extends DeviceGroupListState {}

class DeviceGroupListFailure extends DeviceGroupListState {
  final String error;

  const DeviceGroupListFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class DeviceGroupListSuccess extends DeviceGroupListState {
  final List<DeviceGroup> deviceGroups;

  const DeviceGroupListSuccess({required this.deviceGroups});

  @override
  List<Object> get props => [deviceGroups];
}