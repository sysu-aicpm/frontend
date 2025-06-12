import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/bloc/device_group_list/bloc.dart';
import 'package:smart_home_app/bloc/device_group_list/event.dart';
import 'package:smart_home_app/bloc/device_group_list/state.dart';
import 'package:smart_home_app/pages/admin/device_group_detail_page.dart';

class DeviceGroupListPage extends StatelessWidget {
  const DeviceGroupListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeviceGroupListBloc(
        RepositoryProvider.of<ApiClient>(context),
      )..add(LoadDeviceGroupList()),
      child: BlocBuilder<DeviceGroupListBloc, DeviceGroupListState>(
        builder: (context, state) {
          if (state is DeviceGroupListInProgress) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DeviceGroupListSuccess) {
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
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DeviceGroupDetailPage(deviceGroup: deviceGroup),
                      ),
                    );
                  },
                );
              },
            );
          }
          if (state is DeviceGroupListFailure) {
            return Center(child: Text(state.error));
          }
          return const Center(child: Text('Something went wrong.'));
        },
      )
    );
  }
} 