import 'package:equatable/equatable.dart';
import 'package:smart_home_app/api/models/user_group.dart';

abstract class UserGroupOverviewState extends Equatable {
  const UserGroupOverviewState();

  @override
  List<Object> get props => [];
}

class UserGroupOverviewInitial extends UserGroupOverviewState {}

class UserGroupOverviewInProgress extends UserGroupOverviewState {}

class UserGroupOverviewFailure extends UserGroupOverviewState {
  final String error;

  const UserGroupOverviewFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class UserGroupOverviewSuccess extends UserGroupOverviewState {
  final List<UserGroup> userGroups;

  const UserGroupOverviewSuccess({required this.userGroups});

  @override
  List<Object> get props => [userGroups];
}