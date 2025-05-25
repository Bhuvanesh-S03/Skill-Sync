import 'package:equatable/equatable.dart';
import 'package:skillsync/models/skill_model.dart';

enum SkillStatus { initial, loading, loaded, error }

class SkillState extends Equatable {
  final SkillStatus status;
  final List<SkillModel> skills;
  final String? errorMessage;

  const SkillState({
    this.status = SkillStatus.initial,
    this.skills = const [],
    this.errorMessage,
  });

  SkillState copyWith({
    SkillStatus? status,
    List<SkillModel>? skills,
    String? errorMessage,
  }) {
    return SkillState(
      status: status ?? this.status,
      skills: skills ?? this.skills,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, skills, errorMessage];
}
