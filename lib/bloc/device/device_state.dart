import 'package:equatable/equatable.dart';
import 'package:smart_home_app/api/models/device.dart';

abstract class DeviceState extends Equatable {
  const DeviceState();

  @override
  List<Object> get props => [];
}

class DeviceInitial extends DeviceState {}

class DeviceLoadInProgress extends DeviceState {}

class DeviceLoadSuccess extends DeviceState {
  final List<Device> devices;

  const DeviceLoadSuccess({required this.devices});

  @override
  List<Object> get props => [devices];
}

class DeviceLoadFailure extends DeviceState {
  final String error;

  const DeviceLoadFailure({required this.error});

  @override
  List<Object> get props => [error];
} 