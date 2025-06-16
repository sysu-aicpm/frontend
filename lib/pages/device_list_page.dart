import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/api/models/device.dart';
import 'package:smart_home_app/bloc/device_list/bloc.dart';
import 'package:smart_home_app/bloc/device_list/event.dart';
import 'package:smart_home_app/bloc/device_list/state.dart';
import 'package:smart_home_app/pages/device_detail_page.dart';
import 'package:smart_home_app/utils/styles.dart';

class DeviceListPage extends StatefulWidget {
  const DeviceListPage({super.key});

  @override
  State<DeviceListPage> createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<DeviceListPage> {
  List<FakeDevice> fakeDevices = [];

  @override
  Widget build(BuildContext context) {
    final bloc = DeviceListBloc(
      RepositoryProvider.of<ApiClient>(context),
    );
    return BlocProvider(
      create: (context) => bloc..add(LoadDeviceList()),
      child: BlocBuilder<DeviceListBloc, DeviceListState>(
        builder: (context, state) {
          if (state is DeviceListInProgress) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DeviceListSuccess) {
            final devices = state.devices;
            if (devices.isEmpty) {
              return const Center(child: Text('No devices found.'));
            }
            if (fakeDevices.isEmpty) {
              fakeDevices = devices.map((_) => FakeDevice()).toList();
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                // 根据屏幕宽度计算列数
                int crossAxisCount;
                if (constraints.maxWidth > 2400) {
                  crossAxisCount = 7;
                } else if (constraints.maxWidth > 2000) {
                  crossAxisCount = 6;
                } else if (constraints.maxWidth > 1600) {
                  crossAxisCount = 5;
                } else if (constraints.maxWidth > 1200) {
                  crossAxisCount = 4;
                } else if (constraints.maxWidth > 800) {
                  crossAxisCount = 3;
                } else if (constraints.maxWidth > 500) {
                  crossAxisCount = 2;
                } else {
                  crossAxisCount = 1;
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1, // 调整卡片宽高比
                  ),
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    final fakeDevice = fakeDevices[index];
                    return _buildDeviceCard(bloc, context, device, fakeDevice);
                  },
                );
              },
            );
          }
          if (state is DeviceListFailure) {
            return Center(child: Text(state.error));
          }
          return const Center(child: Text('Something went wrong.'));
        },
      )
    );
  }
}

class FakeDevice {
  bool isOn = false;
  void toggle() {
    isOn = !isOn;
  }
}

Widget _buildDeviceCard(
    DeviceListBloc bloc, BuildContext context,
    Device device, FakeDevice fakeDevice) {
  return Card(
    elevation: 4,
    shadowColor: Colors.black.withValues(alpha: 0.1),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DeviceDetailPage(device: device),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.blueGrey.withValues(alpha: 0.1)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部状态行
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: device.isOnline
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: device.isOnline ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        device.isOnline ? '在线' : '离线',
                        style: TextStyle(
                          fontSize: 11,
                          color: device.isOnline ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.more_vert,
                  color: Colors.grey[400],
                  size: 18,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 设备图标
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: getDeviceTypeColor(device.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: getDeviceTypeColor(device.type),
                    width: 1,
                  ),
                ),
                child: Icon(
                  getDeviceTypeIcon(device.type),
                  color: getDeviceTypeColor(device.type),
                  size: 56,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 设备名称
            Center(
              child: Text(
                device.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 4),

            // 设备类型
            Center(
              child: Text(
                getDeviceTypeName(device.type),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            const SizedBox(height: 8),

            // 假开关控制
            Center(
              child: Switch.adaptive( // 使用 adaptive 可以根据平台自适应样式
                value: fakeDevice.isOn,
                onChanged: (bool newValue) {
                  if(device.isOnline) {  // 在线设备才能控制
                    fakeDevice.toggle();
                    bloc.add(LoadDeviceList());
                  }
                },
                activeColor: Colors.blueAccent, // 开关开启时的颜色
                inactiveThumbColor: Colors.grey, // 开关关闭时滑块的颜色
                inactiveTrackColor: Colors.grey.withValues(alpha: 0.3), // 开关关闭时轨道的颜色
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
