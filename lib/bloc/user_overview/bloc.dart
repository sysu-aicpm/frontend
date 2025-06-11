import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/api/models/user.dart';
import 'package:smart_home_app/bloc/user_overview/event.dart';
import 'package:smart_home_app/bloc/user_overview/state.dart';

class UserOverviewBloc extends Bloc<UserOverviewEvent, UserOverviewState> {
  final ApiClient _apiClient;

  UserOverviewBloc(this._apiClient) : super(UserOverviewInitial()) {
    on<LoadUserOverview>(_onLoadUsers);
  }

  Future<void> _onLoadUsers(
    LoadUserOverview event,
    Emitter<UserOverviewState> emit,
  ) async {
    emit(UserOverviewInProgress());
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
      
      emit(UserOverviewSuccess(users: users));
    } catch (e) {
      emit(UserOverviewFailure(error: 'Failed to load users. $e'));
    }
  }
} 