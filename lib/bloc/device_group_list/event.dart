import 'package:equatable/equatable.dart';

abstract class DeviceGroupListEvent extends Equatable {
  const DeviceGroupListEvent();

  @override
  List<Object> get props => [];
}

class LoadDeviceGroupList extends DeviceGroupListEvent {}