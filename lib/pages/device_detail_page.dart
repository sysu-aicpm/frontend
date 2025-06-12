import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/api/models/device.dart';
import 'package:smart_home_app/bloc/device_detail/bloc.dart';
import 'package:smart_home_app/bloc/device_detail/event.dart';
import 'package:smart_home_app/bloc/device_detail/state.dart';

class DeviceDetailPage extends StatefulWidget {
  final Device device;

  const DeviceDetailPage({super.key, required this.device});

  @override
  DeviceDetailWidgetState createState() => DeviceDetailWidgetState();
}

class DeviceDetailWidgetState extends State<DeviceDetailPage> {
  bool _showLogs = false;
  bool _showUsageRecords = false;
  
  // Pagination controllers
  final int _logsPerPage = 10;
  int _currentLogsPage = 1;
  
  final int _recordsPerPage = 5;
  int _currentRecordsPage = 1;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeviceDetailBloc(
        RepositoryProvider.of<ApiClient>(context),
      )..add(LoadDeviceDetail(widget.device.id)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.device.name),
        ),
        body: BlocConsumer<DeviceDetailBloc, DeviceDetailState>(
          listener: (context, state) {
            if (state is DeviceDetailSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("获取监控信息成功"), backgroundColor: Colors.green),
              );
            }
            if (state is DeviceDetailFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                // 正常情况下是因为没有 monitorable 权限
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
                      Text('Device ID: ${widget.device.id}', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Type: ${widget.device.type}', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Status: ${widget.device.isOnline ? 'Online' : 'Offline'}', style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(child: _buildDeviceDetail(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDeviceDetail(BuildContext context, DeviceDetailState state) {
    if (state is DeviceDetailFailure) {
      return const Center(child: Text("No more information"));
    }
    if (state is DeviceDetailSuccess) {
      final detail = state.detail;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard('Basic Information', [
              _buildInfoRow('Identifier', detail.identifier),
              _buildInfoRow('IP Address', detail.ipAddress),
              _buildInfoRow('Port', detail.port),
              _buildInfoRow('Brand', detail.brand),
              _buildInfoRow('Description', detail.description),
            ]),
            
            _buildInfoCard('Status', [
              _buildInfoRow('Current Power', detail.currentPowerConsumption),
              _buildInfoRow('Uptime', _formatUptime(detail.uptimeSeconds)),
              _buildInfoRow('Last Heartbeat', detail.lastHeartbeat),
            ]),
            
            // Logs section
            Card(
              margin: const EdgeInsets.only(top: 16),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Device Logs'),
                    trailing: Icon(_showLogs ? Icons.expand_less : Icons.expand_more),
                    onTap: () => setState(() => _showLogs = !_showLogs),
                  ),
                  if (_showLogs) ...[
                    _buildLogsList(detail.logs),
                    _buildLogsPagination(detail.logs),
                  ],
                ],
              ),
            ),
            
            // Usage Records section
            Card(
              margin: const EdgeInsets.only(top: 16),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Usage Records'),
                    trailing: Icon(_showUsageRecords ? Icons.expand_less : Icons.expand_more),
                    onTap: () => setState(() => _showUsageRecords = !_showUsageRecords),
                  ),
                  if (_showUsageRecords) ...[
                    _buildUsageRecordsList(detail.usageRecords),
                    _buildRecordsPagination(detail.usageRecords),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }
    // InProgress or Init
    return const Center(child:  CircularProgressIndicator());
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value.isNotEmpty ? value : 'N/A')),
        ],
      ),
    );
  }

  String _formatUptime(String seconds) {
    try {
      final uptime = int.parse(seconds);
      final days = uptime ~/ (24 * 3600);
      final hours = (uptime % (24 * 3600)) ~/ 3600;
      final minutes = (uptime % 3600) ~/ 60;
      final secs = uptime % 60;
      
      return '${days}d ${hours}h ${minutes}m ${secs}s';
    } catch (e) {
      return seconds;
    }
  }

  Widget _buildLogsList(List<DeviceLog> logs) {
    final startIndex = (_currentLogsPage - 1) * _logsPerPage;
    final endIndex = startIndex + _logsPerPage;
    final paginatedLogs = logs.sublist(
      startIndex,
      endIndex.clamp(0, logs.length),
    );

    return Column(
      children: [
        for (var i = 0; i < paginatedLogs.length; i++)
          ListTile(
            title: Text(paginatedLogs[i].message),
            subtitle: Text(paginatedLogs[i].timeStamp),
            leading: Text('${startIndex + i + 1}.'),
          ),
        if (logs.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No logs available'),
          ),
      ],
    );
  }

  Widget _buildLogsPagination(List<DeviceLog> logs) {
    final totalPages = (logs.length / _logsPerPage).ceil();
    if (totalPages <= 1) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentLogsPage > 1
                ? () => setState(() => _currentLogsPage--)
                : null,
          ),
          Text('Page $_currentLogsPage of $totalPages'),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _currentLogsPage < totalPages
                ? () => setState(() => _currentLogsPage++)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildUsageRecordsList(List<DeviceUsageRecord> usageRecords) {
    final startIndex = (_currentRecordsPage - 1) * _recordsPerPage;
    final endIndex = startIndex + _recordsPerPage;
    final paginatedRecords = usageRecords.sublist(
      startIndex,
      endIndex.clamp(0, usageRecords.length),
    );

    return Column(
      children: [
        for (var record in paginatedRecords)
          _buildUsageRecordItem(record, startIndex + paginatedRecords.indexOf(record) + 1),
        if (usageRecords.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No usage records available'),
          ),
      ],
    );
  }

  Widget _buildUsageRecordItem(DeviceUsageRecord record, int index) {
    return ExpansionTile(
      leading: Text('$index.'),
      title: Text('${record.action} by ${record.userEmail}'),
      subtitle: Text(record.timeStamp),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (record.parameters.isNotEmpty) ...[
                const Text('Parameters:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ...record.parameters.entries.map((e) => 
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                    child: Text('${e.key}: ${e.value}'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecordsPagination(List<DeviceUsageRecord> usageRecords) {
    final totalPages = (usageRecords.length / _recordsPerPage).ceil();
    if (totalPages <= 1) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentRecordsPage > 1
                ? () => setState(() => _currentRecordsPage--)
                : null,
          ),
          Text('Page $_currentRecordsPage of $totalPages'),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _currentRecordsPage < totalPages
                ? () => setState(() => _currentRecordsPage++)
                : null,
          ),
        ],
      ),
    );
  }
}

