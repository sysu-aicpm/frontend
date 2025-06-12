import 'package:flutter/material.dart';
import 'package:smart_home_app/api/models/user.dart';

class UserDetailPage extends StatelessWidget {
  final User user;
  
  const UserDetailPage({
    super.key,
    required this.user,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("TODO"));
  }
}