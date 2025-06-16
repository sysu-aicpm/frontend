import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/api/models/device.dart';
import 'package:smart_home_app/api/models/device_group.dart';
import 'package:smart_home_app/bloc/device_group/bloc.dart';
import 'package:smart_home_app/bloc/device_group/event.dart';
import 'package:smart_home_app/bloc/device_group/state.dart';
import 'package:smart_home_app/utils/styles.dart';

class DeviceGroupDetailPage extends StatelessWidget {
  final DeviceGroup deviceGroup;
  
  const DeviceGroupDetailPage({
    super.key,
    required this.deviceGroup,
  });
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeviceGroupBloc(context.read<ApiClient>())
        ..add(LoadDeviceGroupDetail(deviceGroup)),
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
                    _buildDevicesSection(context),
                  ],
                ),
              ),
            ),
          ],
        ),
        // floatingActionButton: _buildAddDeviceFAB(context)
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
          deviceGroup.name,
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
              Icons.group_work,
              size: 80,
              color: Colors.purple.withAlpha(200),
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
            _buildInfoRow('ID', deviceGroup.id),
            const SizedBox(height: 8),
            _buildInfoRow('名称', deviceGroup.name),
            const SizedBox(height: 8),
            _buildInfoRow('描述', deviceGroup.description),
            const SizedBox(height: 8),
            _buildInfoRow('设备数量', '${deviceGroup.devices.length}'),
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
  
  Widget _buildDevicesSection(BuildContext context) {
    return BlocBuilder<DeviceGroupBloc, DeviceGroupState>(
      builder: (context, state) {
        if (state is DeviceGroupLoading || state is DeviceGroupInitial) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (state is DeviceGroupError) {
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
        
        if (state is DeviceGroupLoaded) {
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
                        '组内设备',
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
                          '${state.groupDevices.length} 个设备',
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
                  if (state.groupDevices.isEmpty) 
                    Center(
                      child: Text(
                        "暂无组内设备",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        )
                      )
                    )
                  else
                    ...state.groupDevices.map((device) => _buildDeviceItem(
                      context,
                      device,
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
                        '可添加设备',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (state.availableDevices.isEmpty) 
                    Center(
                      child: Text(
                        "暂无可添加设备",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        )
                      )
                    )
                  else
                    ...state.availableDevices.map((device) => _buildDeviceItem(
                      context,
                      device,
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
  
  Widget _buildDeviceItem(BuildContext context, Device device, {required bool isInGroup}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: getDeviceTypeColor(device.type).withAlpha(100),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            getDeviceTypeIcon(device.type),
            color: getDeviceTypeColor(device.type),
            size: 20,
          ),
        ),
        title: Text(
          device.name,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          'ID: ${device.id}',
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
              // onPressed: () => _showRemoveDeviceDialog(context, device),
              onPressed: () => _rmDeviceFromGroup(context, device),
            )
          : IconButton(
              icon: Icon(
                Icons.add_circle_outline,
                color: Colors.green[600],
              ),
              onPressed: () => _addDeviceToGroup(context, device),
            ),
      ),
    );
  }
  
  void _addDeviceToGroup(BuildContext context, Device device) {
    BlocProvider.of<DeviceGroupBloc>(context).add(AddDeviceToGroup(device.id));
  }

  void _rmDeviceFromGroup(BuildContext context, Device device) {
    BlocProvider.of<DeviceGroupBloc>(context).add(RemoveDeviceFromGroup(device.id));
  }
}