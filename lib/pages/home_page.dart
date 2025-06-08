import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/bloc/auth/auth_bloc.dart';
import 'package:smart_home_app/bloc/auth/auth_event.dart';
import 'package:smart_home_app/bloc/device/device_bloc.dart';
import 'package:smart_home_app/bloc/device/device_event.dart';
import 'package:smart_home_app/bloc/device/device_state.dart';
import 'package:smart_home_app/pages/device_details_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeviceBloc(
        // We can get the ApiClient from the repository provider
        // but for simplicity, we create a new one.
        // In a real app, you should use RepositoryProvider to provide ApiClient.
        RepositoryProvider.of<ApiClient>(context),
      )..add(LoadDevices()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Devices'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                // Dispatch logout event
                context.read<AuthBloc>().add(LogoutRequested());
              },
            ),
          ],
        ),
        body: BlocBuilder<DeviceBloc, DeviceState>(
          builder: (context, state) {
            if (state is DeviceLoadInProgress) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is DeviceLoadSuccess) {
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
                    subtitle: Text(device.type),
                    trailing: Icon(
                      Icons.circle,
                      color: device.isOnline ? Colors.green : Colors.red,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DeviceDetailsPage(device: device),
                        ),
                      );
                    },
                  );
                },
              );
            }
            if (state is DeviceLoadFailure) {
              return Center(child: Text(state.error));
            }
            return const Center(child: Text('Something went wrong.'));
          },
        ),
      ),
    );
  }
} 