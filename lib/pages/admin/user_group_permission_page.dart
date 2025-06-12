import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/api/models/device.dart';
import 'package:smart_home_app/api/models/device_group.dart';
import 'package:smart_home_app/api/models/permission.dart';
import 'package:smart_home_app/bloc/user_group_permission/bloc.dart';
import 'package:smart_home_app/bloc/user_group_permission/event.dart';
import 'package:smart_home_app/bloc/user_group_permission/state.dart';
import 'package:smart_home_app/utils/styles.dart';

class UserGroupPermissionPage extends StatefulWidget {
  final String userGroupId;
  
  const UserGroupPermissionPage({
    super.key,
    required this.userGroupId,
  });

  @override
  State<UserGroupPermissionPage> createState() => _UserGroupPermissionPageState();
}

class _UserGroupPermissionPageState extends State<UserGroupPermissionPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = UserGroupPermissionBloc(
      RepositoryProvider.of<ApiClient>(context),
    );
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[600],
        title: const Text(
          '权限管理',
          style: TextStyle(fontWeight: FontWeight.w300),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(150),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: '搜索设备或设备组...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorWeight: 3,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.devices),
                    text: '设备权限',
                  ),
                  Tab(
                    icon: Icon(Icons.group_work),
                    text: '设备组权限',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: BlocProvider(
        create: (context) => bloc..add(LoadUserGroupPermission(widget.userGroupId)),
        child: BlocBuilder<UserGroupPermissionBloc, UserGroupPermissionState>(
          builder: (context, state) {
            if (state is UserGroupPermissionLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is UserGroupPermissionError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '加载失败',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.error,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context
                            .read<UserGroupPermissionBloc>()
                            .add(LoadUserGroupPermission(widget.userGroupId));
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('重试'),
                    ),
                  ],
                ),
              );
            }

            if (state is UserGroupPermissionLoaded) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildDevicePermissionsTab(state, bloc),
                  _buildDeviceGroupPermissionsTab(state, bloc),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        )
      ),
    );
  }

  Widget _buildDevicePermissionsTab(UserGroupPermissionLoaded state, UserGroupPermissionBloc bloc) {
    final allDevices = [...state.permissionDevices, ...state.nonePermissionDevices];
    final filteredDevices = allDevices.where((device) {
      return device.name.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filteredDevices.isEmpty) {
      return _buildEmptyState('暂无设备', Icons.devices_other);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredDevices.length,
      itemBuilder: (context, index) {
        final device = filteredDevices[index];
        final permission = state.devicePermissions.firstWhere(
          (p) => p.deviceId.toString() == device.id,
          orElse: () => DevicePermission(
            deviceId: num.parse(device.id),
            level: PermissionLevel.none,
          ),
        );

        return _buildDeviceCard(device, permission, bloc);
      },
    );
  }

  Widget _buildDeviceGroupPermissionsTab(UserGroupPermissionLoaded state, UserGroupPermissionBloc bloc) {
    final allDeviceGroups = [
      ...state.permissionDeviceGroups,
      ...state.nonePermissionDeviceGroups
    ];
    final filteredDeviceGroups = allDeviceGroups.where((group) {
      return group.name.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filteredDeviceGroups.isEmpty) {
      return _buildEmptyState('暂无设备组', Icons.group_work);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredDeviceGroups.length,
      itemBuilder: (context, index) {
        final deviceGroup = filteredDeviceGroups[index];
        final permission = state.deviceGroupPermissions.firstWhere(
          (p) => p.deviceGroupId.toString() == deviceGroup.id,
          orElse: () => DeviceGroupPermission(
            deviceGroupId: num.parse(deviceGroup.id),
            level: PermissionLevel.none,
          ),
        );

        return _buildDeviceGroupCard(deviceGroup, permission, bloc);
      },
    );
  }

  Widget _buildDeviceCard(Device device, DevicePermission permission, UserGroupPermissionBloc bloc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: getDeviceTypeColor(device.type).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            getDeviceTypeIcon(device.type),
            color: getDeviceTypeColor(device.type),
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                device.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: device.isOnline ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              device.isOnline ? '在线' : '离线',
              style: TextStyle(
                fontSize: 12,
                color: device.isOnline ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              getDeviceTypeName(device.type),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            _buildPermissionSelector(
              permission.level,
              (newLevel) {
                bloc.add(UpdateUserGroupPermissionOnDevice(device.id, newLevel));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceGroupCard(
    DeviceGroup deviceGroup,
    DeviceGroupPermission permission,
    UserGroupPermissionBloc bloc
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.group_work,
            color: Colors.purple,
            size: 24,
          ),
        ),
        title: Text(
          deviceGroup.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              deviceGroup.description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '包含 ${deviceGroup.devices.length} 个设备',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            _buildPermissionSelector(
              permission.level,
              (newLevel) {
                bloc.add(
                  UpdateUserGroupPermissionOnDeviceGroup(
                    deviceGroup.id,
                    newLevel,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionSelector(
    PermissionLevel currentLevel,
    Function(PermissionLevel) onLevelChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<PermissionLevel>(
          value: currentLevel,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          style: const TextStyle(fontSize: 14),
          items: PermissionLevel.values.map((level) {
            return DropdownMenuItem(
              value: level,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: getPermissionLevelColor(level),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    getPermissionLevelName(level),
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: level == currentLevel
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (level) {
            if (level != null) {
              onLevelChanged(level);
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}