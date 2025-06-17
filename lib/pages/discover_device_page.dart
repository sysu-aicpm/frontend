import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/bloc/device_list/bloc.dart';
import 'package:smart_home_app/bloc/device_list/event.dart';
import 'package:smart_home_app/bloc/device_list/state.dart';

class DeviceDiscoveryPage extends StatelessWidget {
  const DeviceDiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeviceListBloc(
        RepositoryProvider.of<ApiClient>(context)
      )..add(DiscoverNewDevice()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('发现新设备'),
          centerTitle: true,
        ),
        body: const DeviceDiscoveryView(),
      ),
    );
  }
}

class DeviceDiscoveryView extends StatelessWidget {
  const DeviceDiscoveryView({super.key});

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeviceListBloc, DeviceListState>(
      listener: (context, state) {
        if (state is DiscoverNewDeviceSuccess && state.newDeviceAdded) {
          _showSnackBar(context, '新设备添加成功!');
        } else if (state is DeviceListFailure) {
          _showSnackBar(context, 'Error: ${state.error}', isError: true);
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  context.read<DeviceListBloc>().add(DiscoverNewDevice());
                },
                icon: const Icon(Icons.search),
                label: const Text('点击开始扫描'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _buildBody(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, DeviceListState state) {
    if (state is DiscoverNewDeviceSuccess) {
      if (state.datas.isEmpty) {
        return const Center(
          child: Text(
            '没有找到新设备',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      }
      return ListView.builder(
        itemCount: state.datas.length,
        itemBuilder: (context, index) {
          final device = state.datas[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Type: ${device.deviceType.toString().split('.').last}'),
                  Text('Identifier: ${device.deviceIdentifier}'),
                  Text('IP: ${device.ip}:${device.port}'),
                  Text('Status: ${device.status}'),
                  Text('Power: ${device.power}'),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<DeviceListBloc>().add(SyncDevice(data: device));
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Device'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else if (state is DeviceListFailure) {
      return Center(
        child: Text(
          'Failed to load devices: ${state.error}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    } else {
      return Center(
        child: Column(
          children: [
            Spacer(),
            Image.asset(
              'assets/images/taffy/66.png',
              height: 200,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(),
            Spacer()
          ],
        )
      );
    }
  }
}