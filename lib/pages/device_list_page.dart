import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/bloc/device_list/bloc.dart';
import 'package:smart_home_app/bloc/device_list/event.dart';
import 'package:smart_home_app/bloc/device_list/state.dart';
import 'package:smart_home_app/pages/device_detail_page.dart';

class DeviceListPage extends StatelessWidget {
  const DeviceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeviceListBloc(
        RepositoryProvider.of<ApiClient>(context),
      )..add(LoadDeviceList()),
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
            return ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return ListTile(
                  title: Text(device.name),
                  subtitle: Text(device.type.name),
                  trailing: Icon(
                    Icons.circle,
                    color: device.isOnline ? Colors.green : Colors.red,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DeviceDetailPage(device: device),
                      ),
                    );
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