import 'package:equatable/equatable.dart';

class DeviceGroup extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<num> devices;

  const DeviceGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.devices,
  });

  @override
  List<Object> get props => [id, name, description, devices];
}

extension DeviceGroupExtension on DeviceGroup {
  DeviceGroup copyWith({
    String? id,
    String? name,
    String? description,
    List<num>? devices,
  }) {
    return DeviceGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      devices: devices ?? this.devices,
    );
  }
}