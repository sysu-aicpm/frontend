import 'package:smart_home_app/api/models/device.dart';

abstract class ControlAction {
  String getAction();
  bool setParameters();
  Map<String, String> parameters = {};
}

class SetTemperature extends ControlAction {
  int temperature = 16;

  @override
  String getAction(){
    return "set_temperature";
  }
}


class Switch extends ControlAction {
  bool on = true;

  @override
  String getAction(){
    return "switch";
  }
}


class SetBrightness extends ControlAction {
  int brighness = 0;

  @override
  String getAction(){
    return "set_brighness";
  }
}


class SetLock extends ControlAction {
  bool on = true;

  @override
  String getAction(){
    return "set_lock";
  }
}


class SetRecording extends ControlAction {
  bool start = true;  // false: stop

  @override
  String getAction(){
    return "set_recording";
  }
}

enum Resolution {
  _720p,
  _1080p,
  _4k;
}

class SetResolution extends ControlAction {
  Resolution resolution = Resolution._1080p;

  @override
  String getAction(){
    return "set_resolution";
  }
}


List<ControlAction> getControlActions(DeviceType type) {
  switch (type) {
    case DeviceType.air_conditioner:
      return [SetTemperature(), Switch()];
    case DeviceType.refrigerator:
      return [SetTemperature(), Switch()];
    case DeviceType.light:
      return [SetBrightness(), Switch()];
    case DeviceType.lock:
      return [SetLock()];
    case DeviceType.camera:
      return [SetRecording(), SetResolution()];
    case DeviceType.unknown:
      return [];
  }
}