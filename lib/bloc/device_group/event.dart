import 'package:smart_home_app/api/models/device_group.dart';

abstract class DeviceGroupEvent {}

class LoadDeviceGroupDetail extends DeviceGroupEvent {
  final DeviceGroup deviceGroup;
  LoadDeviceGroupDetail(this.deviceGroup);
}

class AddDeviceToGroup extends DeviceGroupEvent {
  final String deviceId;
  AddDeviceToGroup(this.deviceId);
}

class RemoveDeviceFromGroup extends DeviceGroupEvent {
  final String deviceId;
  RemoveDeviceFromGroup(this.deviceId);
}