import 'package:smart_home_app/api/models/user_group.dart';

abstract class UserGroupEvent {}

class LoadUserGroupDetail extends UserGroupEvent {
  final UserGroup userGroup;
  LoadUserGroupDetail(this.userGroup);
}

class AddUserToGroup extends UserGroupEvent {
  final String userId;
  AddUserToGroup(this.userId);
}

class RemoveUserFromGroup extends UserGroupEvent {
  final String userId;
  RemoveUserFromGroup(this.userId);
}