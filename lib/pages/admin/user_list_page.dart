import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/api/models/user.dart';
import 'package:smart_home_app/bloc/user_list/bloc.dart';
import 'package:smart_home_app/bloc/user_list/event.dart';
import 'package:smart_home_app/bloc/user_list/state.dart';
import 'package:smart_home_app/pages/admin/user_permission_page.dart';

class UserListPage extends StatelessWidget {
  const UserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = UserListBloc(
      RepositoryProvider.of<ApiClient>(context),
    );
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocProvider(
        create: (context) => bloc..add(LoadUserList()),
        child: BlocConsumer<UserListBloc, UserListState>(
          listener: (context, state) {
            if (state is UserListFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red[400],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is UserListInProgress) {
              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.blue,
                ),
              );
            }
            
            if (state is UserListSuccess) {
              final users = state.users;
              
              if (users.isEmpty) {
                return _buildEmptyState(context);
              }
              
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<UserListBloc>().add(LoadUserList());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return _buildUserCard(context, user, index);
                  },
                ),
              );
            }
            
            return Center(child: Text("加载失败"));
          },
        ),
      )
    );
  }

  Widget _buildUserCard(BuildContext context, User user, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    user.isStaff
                      ? Icons.manage_accounts
                      : Icons.person,
                    color: user.isStaff 
                      ? Colors.purple[300]
                      : Colors.blue[300],
                    size: 20,
                  )
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'permission') {               
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => UserPermissionPage(userId: user.id),
                        ),
                      );
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'permission',
                      child: Row(
                        children: [
                          Icon(
                            Icons.security,
                            color: Colors.purple[400],
                            size: 18,
                          ),
                          SizedBox(width: 12),
                          Text(
                            '权限管理',
                            style: TextStyle(
                              color: Colors.purple[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  ]
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.not_interested,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Users',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ]
        )
      ),
    );
  }
}