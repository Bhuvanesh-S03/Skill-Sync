import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String name;
  final List<String> skills;
  final List<String> interestedSkills;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.skills = const [],
    this.interestedSkills = const [],
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      skills: List<String>.from(map['skills'] ?? []),
      interestedSkills: List<String>.from(map['interestedSkills'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'skills': skills,
      'interestedSkills': interestedSkills,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    List<String>? skills,
    List<String>? interestedSkills,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      skills: skills ?? this.skills,
      interestedSkills: interestedSkills ?? this.interestedSkills,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object> get props => [
    id,
    email,
    name,
    skills,
    interestedSkills,
    createdAt,
  ];
}
