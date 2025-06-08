import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/api/models/device.dart';
import 'package:smart_home_app/bloc/permission/permission_bloc.dart';
import 'package:smart_home_app/bloc/permission/permission_event.dart';
import 'package:smart_home_app/bloc/permission/permission_state.dart';
import 'package:smart_home_app/pages/share_device_dialog.dart';

class DeviceDetailsPage extends StatelessWidget {
  final Device device;

  const DeviceDetailsPage({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PermissionBloc(
        RepositoryProvider.of<ApiClient>(context),
      )..add(LoadPermissions(device.id)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(device.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => ShareDeviceDialog(deviceId: device.id),
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<PermissionBloc, PermissionState>(
          listener: (context, state) {
            if (state is PermissionUpdateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
            }
            if (state is PermissionUpdateFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                // Device Info
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Device ID: ${device.id}', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Type: ${device.type}', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Status: ${device.isOnline ? 'Online' : 'Offline'}', style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                const Divider(),
                // Permissions Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Shared With', style: Theme.of(context).textTheme.headline6),
                ),
                Expanded(child: _buildPermissionsList(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPermissionsList(BuildContext context, PermissionState state) {
    if (state is PermissionLoadInProgress || state is PermissionUpdateInProgress) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is PermissionLoadSuccess) {
      if (state.permissions.isEmpty) {
        return const Center(child: Text('Not shared with anyone.'));
      }
      return ListView.builder(
        itemCount: state.permissions.length,
        itemBuilder: (context, index) {
          final permission = state.permissions[index];
          return ListTile(
            title: Text(permission.username),
            subtitle: Text('Role: ${permission.permissionLevel.name}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Revoke Permission'),
                    content: Text('Are you sure you want to revoke permission from ${permission.username}?'),
                    actions: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      TextButton(
                        child: const Text('Revoke'),
                        onPressed: () {
                          context.read<PermissionBloc>().add(RevokePermission(permission.id));
                          // After revoking, we should also reload the list.
                          // The bloc doesn't do this automatically, so let's add it here for now.
                          context.read<PermissionBloc>().add(LoadPermissions(device.id));
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      );
    }
    if (state is PermissionLoadFailure) {
      return Center(child: Text(state.error));
    }
    // Handle other states like update success/failure by just showing the previous list
    // A more sophisticated implementation might handle this differently.
    if(state is PermissionUpdateSuccess || state is PermissionUpdateFailure || state is PermissionInitial) {
       // This part needs to be improved.
       // Ideally we'd get the permission list from the state, but after an update, the state is not PermissionLoadSuccess anymore.
       // The BLoC reloads the list, so we will eventually get a new PermissionLoadSuccess.
       return const Center(child: Text(' ')); // show nothing while reloading
    }
    return const Center(child: Text('Could not load permissions.'));
  }
} 