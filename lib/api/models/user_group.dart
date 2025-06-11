import 'package:equatable/equatable.dart';

class UserGroup extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<num> members;

  const UserGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.members,
  });

  @override
  List<Object> get props => [id, name, description, members];
}