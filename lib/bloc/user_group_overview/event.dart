import 'package:equatable/equatable.dart';

abstract class UserGroupOverviewEvent extends Equatable {
  const UserGroupOverviewEvent();

  @override
  List<Object> get props => [];
}

class LoadUserGroupOverview extends UserGroupOverviewEvent {}