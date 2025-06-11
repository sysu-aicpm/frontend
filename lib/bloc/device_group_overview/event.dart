import 'package:equatable/equatable.dart';

abstract class DeviceGroupOverviewEvent extends Equatable {
  const DeviceGroupOverviewEvent();

  @override
  List<Object> get props => [];
}

class LoadDeviceGroupOverview extends DeviceGroupOverviewEvent {}