import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/api/models/user_group.dart';
import 'package:smart_home_app/bloc/user_group_overview/event.dart';
import 'package:smart_home_app/bloc/user_group_overview/state.dart';

class UserGroupOverviewBloc extends Bloc<UserGroupOverviewEvent, UserGroupOverviewState> {
  final ApiClient _apiClient;

  UserGroupOverviewBloc(this._apiClient) : super(UserGroupOverviewInitial()) {
    on<LoadUserGroupOverview>(_onLoadUsers);
  }

  Future<void> _onLoadUsers(
    LoadUserGroupOverview event,
    Emitter<UserGroupOverviewState> emit,
  ) async {
    emit(UserGroupOverviewInProgress());
    try {
      final response = await _apiClient.getUserGroups();
      final userGroups = List<UserGroup>.from(response.data['results']
        .map(
          (json) => UserGroup(
            id: json['id']?.toString() ?? 'Unknown',
            name: json['name'] ?? 'Unknown',
            description: json['description'] ?? 'Unknown',
            members: List<num>.from(json['members'])
          )
        )
        .toList()
        .where((t) => t != null)
      );
      
      emit(UserGroupOverviewSuccess(userGroups: userGroups));
    } catch (e) {
      emit(UserGroupOverviewFailure(error: 'Failed to load user groups. $e'));
    }
  }
} 