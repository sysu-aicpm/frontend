import 'package:equatable/equatable.dart';

abstract class DeviceDetailEvent extends Equatable {
  const DeviceDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadDeviceDetail extends DeviceDetailEvent {
  final String deviceId;

  const LoadDeviceDetail(this.deviceId);

  @override
  List<Object> get props => [deviceId];
}