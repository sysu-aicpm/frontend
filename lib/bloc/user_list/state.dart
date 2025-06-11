import 'package:equatable/equatable.dart';
import 'package:smart_home_app/api/models/user.dart';

abstract class UserListState extends Equatable {
  const UserListState();

  @override
  List<Object> get props => [];
}

class UserListInitial extends UserListState {}

class UserListInProgress extends UserListState {}

class UserListFailure extends UserListState {
  final String error;

  const UserListFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class UserListSuccess extends UserListState {
  final List<User> users;

  const UserListSuccess({required this.users});

  @override
  List<Object> get props => [users];
}