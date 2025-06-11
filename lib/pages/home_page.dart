import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/bloc/auth/bloc.dart';
import 'package:smart_home_app/bloc/auth/event.dart';
import 'package:smart_home_app/pages/admin/device_groups_page.dart';
import 'package:smart_home_app/pages/admin/user_groups_page.dart';
import 'package:smart_home_app/pages/admin/users_page.dart';
import 'package:smart_home_app/pages/device_overview_page.dart';

class HomePage extends StatefulWidget {
  final bool isStaff;
  const HomePage({super.key, required this.isStaff});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // 默认显示第一个页面

  // 页面列表
  final List<Widget> _pages = [
    const DeviceOverviewPage(),
    const DeviceGroupsPage(),
    const UsersPage(),
    const UserGroupsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Home'),
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
      body: _pages[_currentIndex],
      // 只有当 isStaff 为 true 时也就是用户为管理员时才显示底部导航栏
      bottomNavigationBar: 
        widget.isStaff ? BottomNavigationBar(
          selectedItemColor: Colors.blue.shade900,
          unselectedItemColor: Colors.blue.shade600,
          backgroundColor: Colors.blue.shade200,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Devices',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business),
              label: 'Device Groups',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business),
              label: 'Users',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school),
              label: 'User Groups',
            ),
          ],
        )
        : null,
    );
  }
}