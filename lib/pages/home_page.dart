import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_app/bloc/auth/bloc.dart';
import 'package:smart_home_app/bloc/auth/event.dart';
import 'package:smart_home_app/bloc/auth/state.dart';
import 'package:smart_home_app/flutter_chat_desktop/presentation/chat_screen.dart';
import 'package:smart_home_app/pages/admin/device_group_list_page.dart';
import 'package:smart_home_app/pages/admin/user_group_list_page.dart';
import 'package:smart_home_app/pages/admin/user_list_page.dart';
import 'package:smart_home_app/pages/device_list_page.dart';
import 'package:smart_home_app/pages/login_page.dart';

class HomePage extends StatefulWidget {
  final bool isStaff;
  const HomePage({super.key, required this.isStaff});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // 默认显示第一个页面

  List<Widget> _pages(bool isStaff) {
    List<Widget> pages = [];
    pages.add(const DeviceListPage());
    if (isStaff) {
      pages.add(const DeviceGroupListPage());
      pages.add(const UserListPage());
      pages.add(const UserGroupListPage());
    }
    pages.add(const ChatScreen());
    return pages;
  }

  List<BottomNavigationBarItem> _items(bool isStaff) {
    List<BottomNavigationBarItem> items = [];
    
    items.add(BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Devices',
    ));
    if (isStaff) {
      items.add(BottomNavigationBarItem(
        icon: Icon(Icons.group_work),
        label: 'Device Groups',
      ));
      items.add(BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Users',
      ));
      items.add(BottomNavigationBarItem(
        icon: Icon(Icons.groups),
        label: 'User Groups',
      ));
    }
    items.add(BottomNavigationBarItem(
      icon: Icon(Icons.forum),
      label: 'AI Chat',
    ));

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Center(child: Image.asset(
            'assets/images/aicpm.png',
            height: 60,
            fit: BoxFit.contain,
          )),
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
        body: _pages(widget.isStaff)[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.blue.shade900,
          unselectedItemColor: Colors.blue.shade600,
          backgroundColor: Colors.blue.shade200,
          currentIndex:  _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: _items(widget.isStaff),
        )
      ),
    );
  }
}