import 'package:equatable/equatable.dart';
import 'package:smart_home_app/api/models/user_group.dart';

abstract class UserGroupListState extends Equatable {
  const UserGroupListState();

  @override
  List<Object> get props => [];
}

class UserGroupListInitial extends UserGroupListState {}

class UserGroupListInProgress extends UserGroupListState {}

class UserGroupListFailure extends UserGroupListState {
  final String error;

  const UserGroupListFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class UserGroupListSuccess extends UserGroupListState {
  final List<UserGroup> userGroups;

  const UserGroupListSuccess({required this.userGroups});

  @override
  List<Object> get props => [userGroups];
}