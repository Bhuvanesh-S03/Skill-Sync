import 'package:equatable/equatable.dart';

class SkillModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String category;
  final String userId;
  final String userName;
  final DateTime createdAt;

  const SkillModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.userId,
    required this.userName,
    required this.createdAt,
  });

  factory SkillModel.fromMap(Map<String, dynamic> map, String id) {
    return SkillModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'userId': userId,
      'userName': userName,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  @override
  List<Object> get props => [
    id,
    name,
    description,
    category,
    userId,
    userName,
    createdAt,
  ];
}
