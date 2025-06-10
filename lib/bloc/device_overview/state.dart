import 'package:equatable/equatable.dart';
import 'package:smart_home_app/api/models/device.dart';

abstract class DeviceOverviewState extends Equatable {
  const DeviceOverviewState();

  @override
  List<Object> get props => [];
}

class DeviceOverviewInitial extends DeviceOverviewState {}

class DeviceOverviewInProgress extends DeviceOverviewState {}

class DeviceOverviewFailure extends DeviceOverviewState {
  final String error;

  const DeviceOverviewFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class DeviceOverviewSuccess extends DeviceOverviewState {
  final List<Device> devices;

  const DeviceOverviewSuccess({required this.devices});

  @override
  List<Object> get props => [devices];
}