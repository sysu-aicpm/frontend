import 'package:equatable/equatable.dart';
import 'package:smart_home_app/api/models/user.dart';

abstract class UserOverviewState extends Equatable {
  const UserOverviewState();

  @override
  List<Object> get props => [];
}

class UserOverviewInitial extends UserOverviewState {}

class UserOverviewInProgress extends UserOverviewState {}

class UserOverviewFailure extends UserOverviewState {
  final String error;

  const UserOverviewFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class UserOverviewSuccess extends UserOverviewState {
  final List<User> users;

  const UserOverviewSuccess({required this.users});

  @override
  List<Object> get props => [users];
}