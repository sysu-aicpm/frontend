import 'package:equatable/equatable.dart';

abstract class UserGroupListEvent extends Equatable {
  const UserGroupListEvent();

  @override
  List<Object> get props => [];
}

class LoadUserGroupList extends UserGroupListEvent {}

class CreateUserGroup extends UserGroupListEvent {
  final String name;
  final String? description;
  const CreateUserGroup(this.name, this.description);

  @override
  List<Object> get props => [name];
}

class RemoveUserGroup extends UserGroupListEvent {
  final String userGroupId;
  const RemoveUserGroup(this.userGroupId);

  @override
  List<Object> get props => [userGroupId];
}