import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/api/models/user.dart';
import 'package:smart_home_app/api/models/user_group.dart';
import 'package:smart_home_app/bloc/user_group/event.dart';
import 'package:smart_home_app/bloc/user_group/state.dart';

class UserGroupBloc extends Bloc<UserGroupEvent, UserGroupState> {
  final ApiClient _apiClient;
  
  UserGroupBloc(this._apiClient) : super(UserGroupInitial()) {
    on<LoadUserGroupDetail>(_onLoadUserGroupDetail);
    on<AddUserToGroup>(_onAddUserToGroup);
    on<RemoveUserFromGroup>(_onRemoveUserFromGroup);
  }
  
  Future<void> _onLoadUserGroupDetail(
    LoadUserGroupDetail event,
    Emitter<UserGroupState> emit,
  ) async {
    emit(UserGroupLoading());
    try {
      // 获取所有用户
      final allUsersResponse = await _apiClient.getUsers();
      final allUsers = List<User>.from(allUsersResponse.data['results']
        .map((userJson) => User(
            id: userJson['id']?.toString() ?? 'Unknown',
            email: userJson['email'] ?? 'Unknown',
            username: userJson['username'] ?? 'Unknown',
            firstname: userJson['first_name'] ?? 'Unknown',
            lastname: userJson['last_name'] ?? 'Unknown',
            isStaff: userJson['is_staff'] ?? false,
          )
        ))
        .toList();
      
      // 筛选出组内用户和其他可添加用户
      final groupUsers = allUsers.where((user) => 
        event.userGroup.members.contains(num.parse(user.id))).toList();
      final availableUsers = allUsers.where((user) => 
        !event.userGroup.members.contains(num.parse(user.id))).toList();
      
      emit(UserGroupLoaded(
        userGroup: event.userGroup,
        groupUsers: groupUsers,
        availableUsers: availableUsers,
      ));
    } catch (e) {
      emit(UserGroupError('Failed to load user group details: $e'));
    }
  }
  
  Future<void> _onAddUserToGroup(
    AddUserToGroup event,
    Emitter<UserGroupState> emit,
  ) async {
    final currentState = state;
    if (currentState is UserGroupLoaded) {
      try {
        // 调用 API 添加用户到组
        await _apiClient.addUserToUserGroup(
          num.parse(currentState.userGroup.id), 
          num.parse(event.userId)
        );
        
        // 重新加载数据
        final updatedGroup = UserGroup(
          id: currentState.userGroup.id,
          name: currentState.userGroup.name,
          description: currentState.userGroup.description,
          members: [...currentState.userGroup.members, num.parse(event.userId)],
        );
        
        add(LoadUserGroupDetail(updatedGroup));
      } catch (e) {
        emit(UserGroupError('Failed to add user to group: $e'));
      }
    }
  }
  
  Future<void> _onRemoveUserFromGroup(
    RemoveUserFromGroup event,
    Emitter<UserGroupState> emit,
  ) async {
    final currentState = state;
    if (currentState is UserGroupLoaded) {
      try {
        // 调用 API 从组中移除用户
        await _apiClient.rmUserFromUserGroup(
          num.parse(currentState.userGroup.id), 
          num.parse(event.userId)
        );
        
        // 重新加载数据
        final updatedGroup = UserGroup(
          id: currentState.userGroup.id,
          name: currentState.userGroup.name,
          description: currentState.userGroup.description,
          members: currentState.userGroup.members
            .where((id) => id != num.parse(event.userId))
            .toList(),
        );
        
        add(LoadUserGroupDetail(updatedGroup));
      } catch (e) {
        emit(UserGroupError('Failed to remove user from group: $e'));
      }
    }
  }
}