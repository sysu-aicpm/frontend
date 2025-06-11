import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/bloc/user_group_list/bloc.dart';
import 'package:smart_home_app/bloc/user_group_list/event.dart';
import 'package:smart_home_app/bloc/user_group_list/state.dart';

class UserGroupListPage extends StatelessWidget {
  const UserGroupListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserGroupListBloc(
        RepositoryProvider.of<ApiClient>(context),
      )..add(LoadUserGroupList()),
      child: BlocBuilder<UserGroupListBloc, UserGroupListState>(
        builder: (context, state) {
          if (state is UserGroupListInProgress) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is UserGroupListSuccess) {
            final userGroups = state.userGroups;
            if (userGroups.isEmpty) {
              return const Center(child: Text('No user groups found.'));
            }
            return ListView.builder(
              itemCount: userGroups.length,
              itemBuilder: (context, index) {
                final userGroup = userGroups[index];
                return ListTile(
                  title: Text(userGroup.name),
                  subtitle: Text(userGroup.description),
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
          if (state is UserGroupListFailure) {
            return Center(child: Text(state.error));
          }
          return const Center(child: Text('Something went wrong.'));
        },
      )
    );
  }
} 