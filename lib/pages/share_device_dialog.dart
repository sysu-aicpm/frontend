import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/api/api_client.dart';
import 'package:smart_home_app/api/models/permission.dart';
import 'package:smart_home_app/api/models/user.dart';
import 'package:smart_home_app/bloc/permission/permission_bloc.dart';
import 'package:smart_home_app/bloc/permission/permission_event.dart';

class ShareDeviceDialog extends StatefulWidget {
  final String deviceId;

  const ShareDeviceDialog({super.key, required this.deviceId});

  @override
  State<ShareDeviceDialog> createState() => _ShareDeviceDialogState();
}

class _ShareDeviceDialogState extends State<ShareDeviceDialog> {
  final _searchController = TextEditingController();
  List<User> _searchResults = [];
  bool _isLoading = false;
  User? _selectedUser;
  PermissionLevel _selectedRole = PermissionLevel.usable; // Default role

  void _onSearch() async {
    if (_searchController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _selectedUser = null; // Reset selection on new search
      _searchResults = [];
    });

    try {
      final apiClient = RepositoryProvider.of<ApiClient>(context);
      final response = await apiClient.searchUsers(_searchController.text);
      final users = (response.data as List)
          .map((u) => User(id: u['id'], username: u['username']))
          .toList();
      setState(() {
        _searchResults = users;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to search for users.'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Share Device'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Enter username to search',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _onSearch,
                ),
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              )
            else if (_searchResults.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final user = _searchResults[index];
                    return ListTile(
                      title: Text(user.username),
                      onTap: () {
                        setState(() {
                          _selectedUser = user;
                        });
                      },
                      selected: _selectedUser?.id == user.id,
                      selectedTileColor: Colors.blue.withOpacity(0.1),
                    );
                  },
                ),
              ),
            if (_selectedUser != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: DropdownButtonFormField<PermissionLevel>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Select Role',
                    border: OutlineInputBorder(),
                  ),
                  items: PermissionLevel.values.map((PermissionLevel level) {
                    return DropdownMenuItem<PermissionLevel>(
                      value: level,
                      child: Text(level.name),
                    );
                  }).toList(),
                  onChanged: (PermissionLevel? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedRole = newValue;
                      });
                    }
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedUser == null
              ? null
              : () {
                  context.read<PermissionBloc>().add(ShareDevice(
                        deviceId: widget.deviceId,
                        userId: _selectedUser!.id,
                        role: _selectedRole.name,
                      ));
                  Navigator.of(context).pop();
                },
          child: const Text('Share'),
        ),
      ],
    );
  }
} 