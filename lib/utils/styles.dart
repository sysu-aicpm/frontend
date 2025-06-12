import 'package:flutter/material.dart';
import 'package:smart_home_app/api/models/device.dart';
import 'package:smart_home_app/api/models/permission.dart';


IconData getDeviceTypeIcon(DeviceType type) {
  switch (type) {
    case DeviceType.air_conditioner:
      return Icons.ac_unit;
    case DeviceType.refrigerator:
      return Icons.kitchen;
    case DeviceType.light:
      return Icons.lightbulb;
    case DeviceType.lock:
      return Icons.lock;
    case DeviceType.camera:
      return Icons.camera_alt;
    case DeviceType.unknown:
      return Icons.device_unknown;
  }
}

Color getDeviceTypeColor(DeviceType type) {
  switch (type) {
    case DeviceType.air_conditioner:
      return Colors.blue;
    case DeviceType.refrigerator:
      return Colors.green;
    case DeviceType.light:
      return Colors.orange;
    case DeviceType.lock:
      return Colors.red;
    case DeviceType.camera:
      return Colors.purple;
    case DeviceType.unknown:
      return Colors.grey;
  }
}

String getDeviceTypeName(DeviceType type) {
  switch (type) {
    case DeviceType.air_conditioner:
      return '空调';
    case DeviceType.refrigerator:
      return '冰箱';
    case DeviceType.light:
      return '灯具';
    case DeviceType.lock:
      return '门锁';
    case DeviceType.camera:
      return '摄像头';
    case DeviceType.unknown:
      return '未知设备';
  }
}

Color getPermissionLevelColor(PermissionLevel level) {
  switch (level) {
    case PermissionLevel.none:
      return Colors.grey;
    case PermissionLevel.visible:
      return Colors.blue;
    case PermissionLevel.usable:
      return Colors.green;
    case PermissionLevel.configurable:
      return Colors.orange;
    case PermissionLevel.monitorable:
      return Colors.purple;
    case PermissionLevel.manageable:
      return Colors.red;
  }
}

String getPermissionLevelName(PermissionLevel level) {
  switch (level) {
    case PermissionLevel.none:
      return '无权限';
    case PermissionLevel.visible:
      return '可见';
    case PermissionLevel.usable:
      return '可用';
    case PermissionLevel.configurable:
      return '可配置';
    case PermissionLevel.monitorable:
      return '可监控';
    case PermissionLevel.manageable:
      return '可管理';
  }
}