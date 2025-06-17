import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/api/models/device.dart';
import 'package:smart_home_app/bloc/device_list/bloc.dart';
import 'package:smart_home_app/bloc/device_list/event.dart';
import 'package:smart_home_app/bloc/device_list/state.dart';
import 'package:smart_home_app/pages/device_detail_page.dart';
import 'package:smart_home_app/pages/discover_device_page.dart';
import 'package:smart_home_app/utils/styles.dart';

class DeviceListPage extends StatefulWidget {
  const DeviceListPage({super.key});

  @override
  State<DeviceListPage> createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<DeviceListPage> {
  bool _isSelectionMode = false;
  final Set<String> _selectedDeviceIds = {};

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedDeviceIds.clear();
      }
    });
  }

  void _onDeviceTap(Device device) {
    if (_isSelectionMode) {
      setState(() {
        if (_selectedDeviceIds.contains(device.id)) {
          _selectedDeviceIds.remove(device.id);
        } else {
          _selectedDeviceIds.add(device.id);
        }
      });
    } else {
      _navigateToDetail(context, device);
    }
  }

  void _navigateToDetail(BuildContext context, Device device) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DeviceDetailPage(device: device),
      ),
    );
    // 强制刷新
    context.read<DeviceListBloc>().add(LoadDeviceList());
  }

  void _deleteSelectedDevices(BuildContext blocContext) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Spacer(),
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 24,
              ),
              SizedBox(width: 12),
              Text('移除设备'),
              SizedBox(width: 24),
              Center(child: Image.asset(
                'assets/images/taffy/107.png',
                height: 160,
                fit: BoxFit.contain,
              )),
              Spacer()
            ]
          ),
          content: Text('Are you sure you want to delete ${_selectedDeviceIds.length} selected devices?'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('移除'),
              onPressed: () {
                final bloc = blocContext.read<DeviceListBloc>();
                for (final id in _selectedDeviceIds) {
                  bloc.add(DeleteDevice(int.parse(id)));
                }
                _toggleSelectionMode();
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeviceListBloc(
        RepositoryProvider.of<ApiClient>(context),
      )..add(LoadDeviceList()),
      child: Builder(builder: (context) {
        return Scaffold(
          body: BlocBuilder<DeviceListBloc, DeviceListState>(
            builder: (context, state) {
              if (state is DeviceListInProgress) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is DeviceListSuccess) {
                final devices = state.devices;
                if (devices.isEmpty) {
                  return const Center(child: Text('没有发现设备。'));
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
                    } else if (constraints.maxWidth > 900) {
                      crossAxisCount = 3;
                    } else if (constraints.maxWidth > 600) {
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
                        childAspectRatio: 1.1,
                      ),
                      itemCount: devices.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _buildDiscoverDeviceCard(context);
                        } else {
                          final device = devices[index - 1];
                          final isSelected = _selectedDeviceIds.contains(device.id);
                          return _buildDeviceCard(
                            context, device, _isSelectionMode, isSelected,
                            (Device d) => _onDeviceTap(d)
                          );
                        }
                      },
                    );
                  },
                );
              }
              if (state is DeviceListFailure) {
                return Center(child: Text(state.error));
              }
              return const Center(child: Text('发生了未知错误。'));
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _toggleSelectionMode,
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
            elevation: 4,
            icon: IconButton(
              icon: Icon(_isSelectionMode ? Icons.close : Icons.edit),
              onPressed: _toggleSelectionMode,
            ),
            label: _isSelectionMode
                ? TextButton(
                    onPressed: _selectedDeviceIds.isEmpty ? null : () => _deleteSelectedDevices(context),
                    child: Text(
                      '移除 (${_selectedDeviceIds.length})',
                      style: TextStyle(
                        color: _selectedDeviceIds.isNotEmpty ? Colors.red : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Text(
                  '移除设备',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      }),
    );
  }
}


class FakeDevice {
  bool isOn = false;
  void toggle() {
    isOn = !isOn;
  }
}


Widget _buildDiscoverDeviceCard(BuildContext context) {

  void navigateToDiscover() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DeviceDiscoveryPage(),
      ),
    );
    // 强制刷新
    context.read<DeviceListBloc>().add(LoadDeviceList());
  }
  
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: InkWell(
      onTap: navigateToDiscover,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.blue.withAlpha(50),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Spacer(),
                Center(
                  child: Icon(
                    Icons.add_circle_outline,
                    color: Colors.blue.withAlpha(200),
                    size: 56
                  ),
                ),
                SizedBox(height: 24),
                Center(
                  child: Text(
                    "发现新设备",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.blue.withAlpha(200),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Spacer(),
              ]
            )
          ]
        )
      )
    )
  );
}


Widget _buildDeviceCard(BuildContext context, Device device, bool isSelectionMode, bool isSelected, Function(Device) onTap) {
  bool isOn = false;

  return Card(
    elevation: 4,
    shadowColor: Colors.black.withOpacity(0.1),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color: isSelected ? Colors.blue : Colors.transparent,
        width: 2,
      ),
    ),
    child: InkWell(
      onTap: () => onTap(device),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.blueGrey.withOpacity(0.1),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部状态行
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: device.isOnline ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
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
                  ],
                ),
                const SizedBox(height: 16),
                // 设备图标
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: getDeviceTypeColor(device.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: getDeviceTypeColor(device.type), width: 1),
                    ),
                    child: Icon(getDeviceTypeIcon(device.type), color: getDeviceTypeColor(device.type), size: 56),
                  ),
                ),
                const SizedBox(height: 16),
                // 设备名称
                Center(
                  child: Text(
                    device.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                // 设备类型
                Center(
                  child: Text(
                    getDeviceTypeName(device.type),
                    style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 8),
                // 开关控制（假开关)
                StatefulBuilder(
                  builder: (context, setState) {
                    return Center(
                      child: Switch.adaptive( // 使用 adaptive 可以根据平台自适应样式
                        value: isOn,
                        onChanged: (bool newValue) {
                          if(device.isOnline) { // 在线设备才能控制
                            setState(() => isOn = newValue);
                          }
                        },
                        activeColor: Colors.blueAccent, // 开关开启时的颜色
                        inactiveThumbColor: Colors.grey, // 开关关闭时滑块的颜色
                        inactiveTrackColor: Colors.grey.withOpacity(0.3), // 开关关闭时轨道的颜色
                      ),
                    );
                  }
                ),
              ],
            ),
            // 设备卡片右上角图标设计
            Positioned(
              top: 4,
              right: 4,
              child: isSelectionMode
                  ? (isSelected
                      ? Container( // 选中状态
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, color: Colors.white, size: 16),
                        )
                      : Container( // 未选中状态
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade400, width: 2),
                          ),
                        ))
                  : const Icon(Icons.more_vert, color: Colors.grey, size: 24),
            ),
          ],
        ),
      ),
    ),
  );
}
