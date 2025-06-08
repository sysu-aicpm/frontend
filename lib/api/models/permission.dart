import 'package:equatable/equatable.dart';

enum PermissionLevel {
  none,
  visible,
  usable,
  configurable,
  monitorable,
  manageable,
}

class UserPermission extends Equatable {
  final String id;
  final String userId;
  final String username; // For display purposes
  final PermissionLevel permissionLevel;

  const UserPermission({
    required this.id,
    required this.userId,
    required this.username,
    required this.permissionLevel,
  });

  @override
  List<Object> get props => [id, userId, username, permissionLevel];

  // Helper to convert string from API to enum
  static PermissionLevel levelFromString(String level) {
    return PermissionLevel.values.firstWhere(
      (e) => e.name == level,
      orElse: () => PermissionLevel.none,
    );
  }
} 