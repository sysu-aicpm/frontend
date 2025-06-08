import 'package:equatable/equatable.dart';
import 'package:smart_home_app/api/models/permission.dart';

abstract class PermissionState extends Equatable {
  const PermissionState();

  @override
  List<Object> get props => [];
}

class PermissionInitial extends PermissionState {}

class PermissionLoadInProgress extends PermissionState {}

class PermissionLoadSuccess extends PermissionState {
  final List<Permission> permissions;

  const PermissionLoadSuccess(this.permissions);

  @override
  List<Object> get props => [permissions];
}

class PermissionLoadFailure extends PermissionState {
  final String error;

  const PermissionLoadFailure(this.error);

  @override
  List<Object> get props => [error];
}

class PermissionUpdateInProgress extends PermissionState {}

class PermissionUpdateSuccess extends PermissionState {
  final String message;

  const PermissionUpdateSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class PermissionUpdateFailure extends PermissionState {
  final String error;

  const PermissionUpdateFailure(this.error);

  @override
  List<Object> get props => [error];
} 