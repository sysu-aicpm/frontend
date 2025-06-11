import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/bloc/device_overview/bloc.dart';
import 'package:smart_home_app/bloc/device_overview/event.dart';
import 'package:smart_home_app/bloc/device_overview/state.dart';
import 'package:smart_home_app/pages/device_details_page.dart';

class DevicesPage extends StatelessWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeviceOverviewBloc(
        RepositoryProvider.of<ApiClient>(context),
      )..add(LoadDevicesOverview()),
      child: BlocBuilder<DeviceOverviewBloc, DeviceOverviewState>(
        builder: (context, state) {
          if (state is DeviceOverviewInProgress) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DeviceOverviewSuccess) {
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
          if (state is DeviceOverviewFailure) {
            return Center(child: Text(state.error));
          }
          return const Center(child: Text('Something went wrong.'));
        },
      )
    );
  }
} 