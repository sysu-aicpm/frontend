import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/api/models/user_group.dart';
import 'package:smart_home_app/bloc/user_group_list/event.dart';
import 'package:smart_home_app/bloc/user_group_list/state.dart';

class UserGroupListBloc extends Bloc<UserGroupListEvent, UserGroupListState> {
  final ApiClient _apiClient;

  UserGroupListBloc(this._apiClient) : super(UserGroupListInitial()) {
    on<LoadUserGroupList>(_onLoadUsers);
    on<CreateUserGroup>(_onCreateUserGroup);
    on<RemoveUserGroup>(_onRemoveUserGroup);
  }

  Future<void> _onLoadUsers(
    LoadUserGroupList event,
    Emitter<UserGroupListState> emit,
  ) async {
    emit(UserGroupListInProgress());
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
      
      emit(UserGroupListSuccess(userGroups: userGroups));
    } catch (e) {
      emit(UserGroupListFailure(error: 'Failed to load user groups. $e'));
    }
  }

  Future<void> _onCreateUserGroup(
    CreateUserGroup event,
    Emitter<UserGroupListState> emit,
  ) async {
    final currentState = state;
    if (currentState is UserGroupListSuccess) {
      try {
        // 调用 api 创建用户组
        await _apiClient.createUserGroup(
          event.name,
          event.description
        );
        
        // 刷新用户组列表
        add(LoadUserGroupList());
      } catch (e) {
        emit(UserGroupListFailure(error: 'Failed to create user group: $e'));
      }
    }
  }
  
  Future<void> _onRemoveUserGroup(
    RemoveUserGroup event,
    Emitter<UserGroupListState> emit,
  ) async {
    final currentState = state;
    if (currentState is UserGroupListSuccess) {
      try {
        await _apiClient.deleteUserGroup(
          num.parse(event.userGroupId)
        );
        
        // 刷新用户组列表
        add(LoadUserGroupList());
      } catch (e) {
        emit(UserGroupListFailure(error: 'Failed to delete user group: $e'));
      }
    }
  }
}