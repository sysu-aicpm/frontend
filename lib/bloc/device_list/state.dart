import 'package:equatable/equatable.dart';
import 'package:smart_home_app/api/models/device.dart';

abstract class DeviceListState extends Equatable {
  const DeviceListState();

  @override
  List<Object> get props => [];
}

class DeviceListInitial extends DeviceListState {}

class DeviceListInProgress extends DeviceListState {}

class DeviceListFailure extends DeviceListState {
  final String error;

  const DeviceListFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class DeviceListSuccess extends DeviceListState {
  final List<Device> devices;

  const DeviceListSuccess({required this.devices});

  @override
  List<Object> get props => [devices];
}