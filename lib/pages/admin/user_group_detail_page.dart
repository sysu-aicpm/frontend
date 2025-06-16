import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/api/models/user.dart';
import 'package:smart_home_app/api/models/user_group.dart';
import 'package:smart_home_app/bloc/user_group/bloc.dart';
import 'package:smart_home_app/bloc/user_group/event.dart';
import 'package:smart_home_app/bloc/user_group/state.dart';

class UserGroupDetailPage extends StatelessWidget {
  final UserGroup userGroup;
  
  const UserGroupDetailPage({
    super.key,
    required this.userGroup,
  });
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserGroupBloc(context.read<ApiClient>())
        ..add(LoadUserGroupDetail(userGroup)),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGroupInfoCard(context),
                    const SizedBox(height: 16),
                    _buildUsersSection(context),
                  ],
                ),
              ),
            ),
          ],
        ),
        // floatingActionButton: _buildAddUserFAB(context)
      ),
    );
  }
  
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          userGroup.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3,
                color: Colors.grey,
              ),
            ],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(),
          child: Center(
            child: Icon(
              Icons.groups,
              size: 80,
              color: Colors.blue.withAlpha(200),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildGroupInfoCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  '组信息',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('ID', userGroup.id),
            const SizedBox(height: 8),
            _buildInfoRow('名称', userGroup.name),
            const SizedBox(height: 8),
            _buildInfoRow('描述', userGroup.description),
            const SizedBox(height: 8),
            _buildInfoRow('用户数量', '${userGroup.members.length}'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildUsersSection(BuildContext context) {
    return BlocBuilder<UserGroupBloc, UserGroupState>(
      builder: (context, state) {
        if (state is UserGroupLoading || state is UserGroupInitial) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (state is UserGroupError) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state.error,
                      style: TextStyle(color: Colors.red[600]),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        if (state is UserGroupLoaded) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.local_offer,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '组内用户',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${state.groupUsers.length} 个用户',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (state.groupUsers.isEmpty) 
                    Center(
                      child: Text(
                        "暂无组内用户",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        )
                      )
                    )
                  else
                    ...state.groupUsers.map((user) => _buildUserItem(
                      context,
                      user,
                      isInGroup: true,
                    )),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.local_offer_outlined,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '可添加用户',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (state.availableUsers.isEmpty) 
                    Center(
                      child: Text(
                        "暂无可添加用户",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        )
                      )
                    )
                  else
                    ...state.availableUsers.map((user) => _buildUserItem(
                      context,
                      user,
                      isInGroup: false,
                    )),
                ],
              ),
            ),
          );
        }
        
        return const SizedBox();
      },
    );
  }
  
  Widget _buildUserItem(BuildContext context, User user, {required bool isInGroup}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: user.isStaff 
              ? Colors.purple[300]?.withAlpha(100)
              : Colors.blue[300]?.withAlpha(100),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            user.isStaff
              ? Icons.manage_accounts
              : Icons.person,
            color: user.isStaff 
              ? Colors.purple[300]
              : Colors.blue[300],
            size: 20,
          ),
        ),
        title: Text(
          user.username,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          'Email: ${user.email}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        trailing: isInGroup
          ? IconButton(
              icon: Icon(
                Icons.remove_circle_outline,
                color: Colors.red[600],
              ),
              onPressed: () => _rmUserFromGroup(context, user),
            )
          : IconButton(
              icon: Icon(
                Icons.add_circle_outline,
                color: Colors.green[600],
              ),
              onPressed: () => _addUserToGroup(context, user),
            ),
      ),
    );
  }
  
  void _addUserToGroup(BuildContext context, User user) {
    BlocProvider.of<UserGroupBloc>(context).add(AddUserToGroup(user.id));
  }

  void _rmUserFromGroup(BuildContext context, User user) {
    BlocProvider.of<UserGroupBloc>(context).add(RemoveUserFromGroup(user.id));
  }
}