
import 'package:equatable/equatable.dart';
import 'package:smart_home_app/api/models/device.dart';

abstract class DeviceDetailState extends Equatable {
  const DeviceDetailState();

  @override
  List<Object> get props => [];
}

class DeviceDetailInitial extends DeviceDetailState {}

class DeviceDetailInProgress extends DeviceDetailState {}

class DeviceDetailFailure extends DeviceDetailState {
  final String error;

  const DeviceDetailFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class DeviceDetailSuccess extends DeviceDetailState {
  final DeviceDetail detail;

  const DeviceDetailSuccess({required this.detail});

  @override
  List<Object> get props => [detail];
}