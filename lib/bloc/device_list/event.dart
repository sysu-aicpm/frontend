import 'package:equatable/equatable.dart';

abstract class DeviceListEvent extends Equatable {
  const DeviceListEvent();

  @override
  List<Object> get props => [];
}

class LoadDeviceList extends DeviceListEvent {}