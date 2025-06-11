import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final String firstname;
  final String lastname;
  final bool isStaff;

  const User({
    required this.id,
    required this.username,
    required this.firstname,
    required this.lastname,
    required this.isStaff,
  });

  @override
  List<Object> get props => [id, username];
} 