import 'package:equatable/equatable.dart';

abstract class UserOverviewEvent extends Equatable {
  const UserOverviewEvent();

  @override
  List<Object> get props => [];
}

class LoadUserOverview extends UserOverviewEvent {}