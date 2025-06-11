import 'package:equatable/equatable.dart';
import 'package:smart_home_app/api/models/device_group.dart';

abstract class DeviceGroupOverviewState extends Equatable {
  const DeviceGroupOverviewState();

  @override
  List<Object> get props => [];
}

class DeviceGroupOverviewInitial extends DeviceGroupOverviewState {}

class DeviceGroupOverviewInProgress extends DeviceGroupOverviewState {}

class DeviceGroupOverviewFailure extends DeviceGroupOverviewState {
  final String error;

  const DeviceGroupOverviewFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class DeviceGroupOverviewSuccess extends DeviceGroupOverviewState {
  final List<DeviceGroup> deviceGroups;

  const DeviceGroupOverviewSuccess({required this.deviceGroups});

  @override
  List<Object> get props => [deviceGroups];
}