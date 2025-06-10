import 'package:equatable/equatable.dart';

abstract class DeviceOverviewEvent extends Equatable {
  const DeviceOverviewEvent();

  @override
  List<Object> get props => [];
}

class LoadDevicesOverview extends DeviceOverviewEvent {}