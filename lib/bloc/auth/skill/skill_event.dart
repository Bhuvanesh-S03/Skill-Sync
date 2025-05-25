import 'package:equatable/equatable.dart';
import 'package:skillsync/models/skill_model.dart';


abstract class SkillEvent extends Equatable {
  const SkillEvent();

  @override
  List<Object> get props => [];
}

class SkillLoadRequested extends SkillEvent {}

class SkillAddRequested extends SkillEvent {
  final SkillModel skill;

  const SkillAddRequested(this.skill);

  @override
  List<Object> get props => [skill];
}

class SkillDeleteRequested extends SkillEvent {
  final String skillId;

  const SkillDeleteRequested(this.skillId);

  @override
  List<Object> get props => [skillId];
}
