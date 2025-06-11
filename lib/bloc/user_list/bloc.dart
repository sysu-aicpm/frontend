import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/api/models/user.dart';
import 'package:smart_home_app/bloc/user_list/event.dart';
import 'package:smart_home_app/bloc/user_list/state.dart';

class UserListBloc extends Bloc<UserListEvent, UserListState> {
  final ApiClient _apiClient;

  UserListBloc(this._apiClient) : super(UserListInitial()) {
    on<LoadUserList>(_onLoadUsers);
  }

  Future<void> _onLoadUsers(
    LoadUserList event,
    Emitter<UserListState> emit,
  ) async {
    emit(UserListInProgress());
    try {
      final response = await _apiClient.getUsers();
      final users = List<User>.from(response.data['results']
        .map(
          (json) => User(
            id: json['id']?.toString() ?? 'Unknown',
            email: json['email'] ?? 'Unknown',
            username: json['username'] ?? 'Unknown',
            firstname: json['first_name'] ?? 'Unknown',
            lastname: json['last_name'] ?? 'Unknown',
            isStaff: json['is_staff'] ?? false,
          )
        )
        .toList()
        .where((t) => t != null)
      );
      
      emit(UserListSuccess(users: users));
    } catch (e) {
      emit(UserListFailure(error: 'Failed to load users. $e'));
    }
  }
} 