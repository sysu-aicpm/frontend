import 'package:equatable/equatable.dart';

class Device extends Equatable {
  final String id;
  final String name;
  final String type;
  final bool isOnline;

  const Device({
    required this.id,
    required this.name,
    required this.type,
    required this.isOnline,
  });

  @override
  List<Object> get props => [id, name, type, isOnline];
} 