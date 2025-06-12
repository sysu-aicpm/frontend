import 'package:equatable/equatable.dart';
import 'package:smart_home_app/api/models/user.dart';
import 'package:smart_home_app/api/models/user_group.dart';

abstract class UserGroupState extends Equatable {
  const UserGroupState();

  @override
  List<Object> get props => [];
}

class UserGroupInitial extends UserGroupState {}

class UserGroupLoading extends UserGroupState {}

class UserGroupLoaded extends UserGroupState {
  final UserGroup userGroup;
  final List<User> groupUsers;
  final List<User> availableUsers;
  
  const UserGroupLoaded({
    required this.userGroup,
    required this.groupUsers,
    required this.availableUsers,
  });

  @override
  List<Object> get props => [userGroup, groupUsers, availableUsers];
}

class UserGroupError extends UserGroupState {
  final String error;
  const UserGroupError(this.error);

  @override
  List<Object> get props => [error];
}