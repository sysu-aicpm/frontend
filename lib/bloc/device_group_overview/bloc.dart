import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/api/models/device_group.dart';
import 'package:smart_home_app/bloc/device_group_overview/event.dart';
import 'package:smart_home_app/bloc/device_group_overview/state.dart';

class DeviceGroupOverviewBloc extends Bloc<DeviceGroupOverviewEvent, DeviceGroupOverviewState> {
  final ApiClient _apiClient;

  DeviceGroupOverviewBloc(this._apiClient) : super(DeviceGroupOverviewInitial()) {
    on<LoadDeviceGroupOverview>(_onLoadUsers);
  }

  Future<void> _onLoadUsers(
    LoadDeviceGroupOverview event,
    Emitter<DeviceGroupOverviewState> emit,
  ) async {
    emit(DeviceGroupOverviewInProgress());
    try {
      final response = await _apiClient.getDeviceGroups();
      final devices = List<DeviceGroup>.from(response.data['results']
        .map(
          (json) => DeviceGroup(
            id: json['id']?.toString() ?? 'Unknown',
            name: json['name'] ?? 'Unknown',
            description: json['description'] ?? 'Unknown',
            devices: List<num>.from(json['devices'])
          )
        )
        .toList()
        .where((t) => t != null)
      );
      
      emit(DeviceGroupOverviewSuccess(deviceGroups: devices));
    } catch (e) {
      emit(DeviceGroupOverviewFailure(error: 'Failed to load device groups. $e'));
    }
  }
} 