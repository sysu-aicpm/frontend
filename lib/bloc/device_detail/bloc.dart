import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/api/models/device.dart';
import 'package:smart_home_app/bloc/device_detail/event.dart';
import 'package:smart_home_app/bloc/device_detail/state.dart';

class DeviceDetailBloc extends Bloc<DeviceDetailEvent, DeviceDetailState> {
  final ApiClient _apiClient;

  DeviceDetailBloc(this._apiClient) : super(DeviceDetailInitial()) {
    on<LoadDeviceDetail>(_onLoadDeviceDetail);
    on<UpdateDeviceInfo>(_onUpdateDeviceInfo);
  }

  Future<void> _onLoadDeviceDetail(
    LoadDeviceDetail event,
    Emitter<DeviceDetailState> emit,
  ) async {
    emit(DeviceDetailInProgress());
    try {
      final id = num.parse(event.deviceId); // TODO: handle FormatException
      final response = await _apiClient.getDeviceDetail(id);
      final data = response.data['data'];
      emit(DeviceDetailSuccess(detail: DeviceDetail(
        identifier: data['device_identifier'] ?? 'Unknown',
        ipAddress: data['ip_address'] ?? 'Unknown',
        port: data['port']?.toString() ?? 'Unknown',
        brand: data['brand'] ?? 'Unknown',
        description: data['description'] ?? 'Unknown',
        currentPowerConsumption: data['current_power_consumption']?.toString() ?? 'Unknown',
        uptimeSeconds: data['uptime_seconds']?.toString() ?? 'Unknown',
        lastHeartbeat: data['latest_heart_beat'] ?? 'Unknown',
        logs: List<DeviceLog>.from(data['logs'].map(
          (logItem) => DeviceLog(
            timeStamp: logItem['timestamp'] ?? 'Unknown',
            message: logItem['log_message'] ?? 'Unknown'
          )
        )),
        usageRecords: List<DeviceUsageRecord>.from(
          data['usage_records'].map((record) => DeviceUsageRecord(
            userEmail: record['user_mail'] ?? 'Unknown',
            action: record['action'] ?? 'Unknown',
            timeStamp: record['timestamp'] ?? 'Unknown',
            parameters: Map<String, String>.from(
              record['parameters'].map(
                (key, value) => MapEntry(
                  key?.toString() ?? 'Unknown',
                  value?.toString() ?? 'Unknown'
                )
              )
            )
          ))
        )
      )));
    } catch (e) {
      emit(DeviceDetailFailure(error: 'Failed to load devices. $e'));
    }
  }

  Future<void> _onUpdateDeviceInfo(
    UpdateDeviceInfo event,
    Emitter<DeviceDetailState> emit,
  ) async {
    emit(DeviceDetailInProgress());
    try {
      final id = num.parse(event.deviceId);
      await _apiClient.updateDeviceInfo(
        id,
        event.name,
        event.description,
        event.brand,
      );
      emit(DeviceDetailUpdateSuccess());
      // Refresh details
      add(LoadDeviceDetail(event.deviceId));
    } catch (e) {
      emit(DeviceDetailFailure(error: 'Failed to update device info. $e'));
    }
  }
}