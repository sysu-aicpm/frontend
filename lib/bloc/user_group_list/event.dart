import 'package:equatable/equatable.dart';

abstract class UserGroupListEvent extends Equatable {
  const UserGroupListEvent();

  @override
  List<Object> get props => [];
}

class LoadUserGroupList extends UserGroupListEvent {}