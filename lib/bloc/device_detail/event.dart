import 'package:equatable/equatable.dart';

abstract class DeviceDetailEvent extends Equatable {
  const DeviceDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadDeviceDetail extends DeviceDetailEvent {
  final String deviceId;

  const LoadDeviceDetail(this.deviceId);

  @override
  List<Object> get props => [deviceId];
}

class UpdateDeviceInfo extends DeviceDetailEvent {
  final String deviceId;
  final String? name;
  final String? description;
  final String? brand;

  const UpdateDeviceInfo(this.deviceId, {this.name, this.description, this.brand});

  @override
  List<Object?> get props => [deviceId, name, description, brand];
}