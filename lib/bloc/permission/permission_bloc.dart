import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/api/models/permission.dart';
import 'package:smart_home_app/bloc/permission/permission_event.dart';
import 'package:smart_home_app/bloc/permission/permission_state.dart';

class PermissionBloc extends Bloc<PermissionEvent, PermissionState> {
  final ApiClient _apiClient;

  PermissionBloc(this._apiClient) : super(PermissionInitial()) {
    on<LoadPermissions>(_onLoadPermissions);
    on<ShareDevice>(_onShareDevice);
    on<RevokePermission>(_onRevokePermission);
  }

  Future<void> _onLoadPermissions(
    LoadPermissions event,
    Emitter<PermissionState> emit,
  ) async {
    emit(PermissionLoadInProgress());
    try {
      final response = await _apiClient.getDevicePermissions(event.deviceId);
      final permissions = (response.data as List)
          .map((p) => UserPermission(
                id: p['id'],
                userId: p['user']['id'],
                username: p['user']['username'],
                permissionLevel: UserPermission.levelFromString(p['permission_level']),
              ))
          .toList();
      emit(PermissionLoadSuccess(permissions));
    } catch (e) {
      emit(const PermissionLoadFailure('Failed to load permissions.'));
    }
  }

  Future<void> _onShareDevice(
    ShareDevice event,
    Emitter<PermissionState> emit,
  ) async {
    emit(PermissionUpdateInProgress());
    try {
      await _apiClient.shareDevice(event.deviceId, event.userId, event.role);
      emit(const PermissionUpdateSuccess('Device shared successfully.'));
      add(LoadPermissions(event.deviceId));
    } catch (e) {
      emit(const PermissionUpdateFailure('Failed to share device.'));
    }
  }

  Future<void> _onRevokePermission(
    RevokePermission event,
    Emitter<PermissionState> emit,
  ) async {
    emit(PermissionUpdateInProgress());
    try {
      await _apiClient.revokePermission(event.permissionId);
      emit(const PermissionUpdateSuccess('Permission revoked successfully.'));
      // Here we assume the UI will trigger a reload.
      // A better way is to pass deviceId with the event or return it from API.
    } catch (e) {
      emit(const PermissionUpdateFailure('Failed to revoke permission.'));
    }
  }
} 