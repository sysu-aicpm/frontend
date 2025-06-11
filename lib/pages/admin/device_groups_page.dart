import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/bloc/device_group_overview/bloc.dart';
import 'package:smart_home_app/bloc/device_group_overview/event.dart';
import 'package:smart_home_app/bloc/device_group_overview/state.dart';

class DeviceGroupsPage extends StatelessWidget {
  const DeviceGroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeviceGroupOverviewBloc(
        RepositoryProvider.of<ApiClient>(context),
      )..add(LoadDeviceGroupOverview()),
      child: BlocBuilder<DeviceGroupOverviewBloc, DeviceGroupOverviewState>(
        builder: (context, state) {
          if (state is DeviceGroupOverviewInProgress) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DeviceGroupOverviewSuccess) {
            final deviceGroups = state.deviceGroups;
            if (deviceGroups.isEmpty) {
              return const Center(child: Text('No device groups found.'));
            }
            return ListView.builder(
              itemCount: deviceGroups.length,
              itemBuilder: (context, index) {
                final deviceGroup = deviceGroups[index];
                return ListTile(
                  title: Text(deviceGroup.name),
                  subtitle: Text(deviceGroup.description),
                  // trailing: Icon(
                  //   Icons.circle,
                  //   color: device. ? Colors.green : Colors.red,
                  // ),
                  // onTap: () {
                  //   Navigator.of(context).push(
                  //     MaterialPageRoute(
                  //       builder: (_) => DeviceDetailPage(device: device),
                  //     ),
                  //   );
                  // },
                );
              },
            );
          }
          if (state is DeviceGroupOverviewFailure) {
            return Center(child: Text(state.error));
          }
          return const Center(child: Text('Something went wrong.'));
        },
      )
    );
  }
} 