import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/bloc/user_overview/bloc.dart';
import 'package:smart_home_app/bloc/user_overview/event.dart';
import 'package:smart_home_app/bloc/user_overview/state.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserOverviewBloc(
        RepositoryProvider.of<ApiClient>(context),
      )..add(LoadUserOverview()),
      child: BlocBuilder<UserOverviewBloc, UserOverviewState>(
        builder: (context, state) {
          if (state is UserOverviewInProgress) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is UserOverviewSuccess) {
            final users = state.users;
            if (users.isEmpty) {
              return const Center(child: Text('No users found.'));
            }
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user.username),
                  subtitle: Text(user.email),
                  // trailing: Icon(
                  //   Icons.circle,
                  //   color: user. ? Colors.green : Colors.red,
                  // ),
                  // onTap: () {
                  //   Navigator.of(context).push(
                  //     MaterialPageRoute(
                  //       builder: (_) => UserDetailPage(device: user),
                  //     ),
                  //   );
                  // },
                );
              },
            );
          }
          if (state is UserOverviewFailure) {
            return Center(child: Text(state.error));
          }
          return const Center(child: Text('Something went wrong.'));
        },
      )
    );
  }
} 