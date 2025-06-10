import 'package:equatable/equatable.dart';


enum DeviceType {
  // ignore: constant_identifier_names
  air_conditioner,
  refrigerator,
  light,
  lock,
  camera,
  unknown;

  static DeviceType fromString(String? value) {
    return DeviceType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DeviceType.unknown,
    );
  }
}


class Device extends Equatable {
  final String id;
  final String name;
  final DeviceType type;
  final bool isOnline;

  const Device({
    required this.id,
    required this.name,
    required this.type,
    required this.isOnline,
  });

  @override
  List<Object> get props => [id, name, type, isOnline];
}


class DeviceUsageRecord extends Equatable {
  final String userEmail;
  final String action;
  final String timeStamp;
  final Map<String, String> parameters;

  const DeviceUsageRecord({
    required this.userEmail,
    required this.action,
    required this.timeStamp,
    required this.parameters,
  });

  @override
  List<Object> get props => [userEmail, action, timeStamp, parameters];
}


class DeviceLog extends Equatable {
  final String message;
  final String timeStamp;

  const DeviceLog({
    required this.timeStamp,
    required this.message,
  });

  @override
  List<Object> get props => [message, timeStamp];
}


class DeviceDetail extends Equatable {
  final String identifier;
  final String ipAddress;
  final String port;
  final String brand;
  final String description;
  final String currentPowerConsumption;
  final String uptimeSeconds;
  final String lastHeartbeat;
  final List<DeviceLog> logs;
  final List<DeviceUsageRecord> usageRecords;

  const DeviceDetail({
    required this.identifier,
    required this.ipAddress,
    required this.port,
    required this.brand,
    required this.description,
    required this.currentPowerConsumption,
    required this.uptimeSeconds,
    required this.lastHeartbeat,
    required this.logs,
    required this.usageRecords
  });

  @override
  List<Object> get props => [
    identifier, ipAddress, port, brand, description, currentPowerConsumption,
    uptimeSeconds, lastHeartbeat, logs, usageRecords
  ];
}