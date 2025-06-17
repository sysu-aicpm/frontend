import 'package:equatable/equatable.dart';
import 'package:smart_home_app/api/models/device.dart';

abstract class DeviceListEvent extends Equatable {
  const DeviceListEvent();

  @override
  List<Object> get props => [];
}

class LoadDeviceList extends DeviceListEvent {}

class DeleteDevice extends DeviceListEvent {
  final int deviceId;

  const DeleteDevice(this.deviceId);

  @override
  List<Object> get props => [deviceId];
}

class DiscoverNewDevice extends DeviceListEvent {}

class SyncDevice extends DeviceListEvent {  // 添加设备到数据库中
  final NewDeviceData data;

  const SyncDevice({
    required this.data
  });
}