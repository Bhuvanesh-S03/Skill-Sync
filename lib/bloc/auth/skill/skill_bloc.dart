import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillsync/bloc/auth/skill/skill_event.dart';
import 'package:skillsync/bloc/auth/skill/skill_state.dart';
import 'package:skillsync/models/skill_model.dart';
import 'package:skillsync/repositories/skill_repository.dart';

class SkillBloc extends Bloc<SkillEvent, SkillState> {
  final SkillRepository _skillRepository;
  StreamSubscription? _skillSubscription;

  SkillBloc({required SkillRepository skillRepository})
    : _skillRepository = skillRepository,
      super(const SkillState()) {
    on<SkillLoadRequested>(_onSkillLoadRequested);
    on<SkillAddRequested>(_onSkillAddRequested);
    on<SkillDeleteRequested>(_onSkillDeleteRequested);
    on<_SkillsUpdated>(_onSkillsUpdated); // Add handler for the private event
  }

  void _onSkillLoadRequested(
    SkillLoadRequested event,
    Emitter<SkillState> emit,
  ) {
    emit(state.copyWith(status: SkillStatus.loading));
    _skillSubscription?.cancel();
    _skillSubscription = _skillRepository.getSkills().listen(
      (skills) => add(_SkillsUpdated(skills)),
    );
  }

  void _onSkillsUpdated(_SkillsUpdated event, Emitter<SkillState> emit) {
    emit(state.copyWith(status: SkillStatus.loaded, skills: event.skills));
  }

  void _onSkillAddRequested(
    SkillAddRequested event,
    Emitter<SkillState> emit,
  ) async {
    try {
      emit(state.copyWith(status: SkillStatus.loading));
      await _skillRepository.addSkill(event.skill);
      add(SkillLoadRequested()); // Refresh the list after adding
    } catch (e) {
      emit(
        state.copyWith(status: SkillStatus.error, errorMessage: e.toString()),
      );
    }
  }

  void _onSkillDeleteRequested(
    SkillDeleteRequested event,
    Emitter<SkillState> emit,
  ) async {
    try {
      emit(state.copyWith(status: SkillStatus.loading));
      await _skillRepository.deleteSkill(event.skillId);
      add(SkillLoadRequested()); // Refresh the list after deletion
    } catch (e) {
      emit(
        state.copyWith(status: SkillStatus.error, errorMessage: e.toString()),
      );
    }
  }

  @override
  Future<void> close() {
    _skillSubscription?.cancel();
    return super.close();
  }
}

class _SkillsUpdated extends SkillEvent {
  final List<SkillModel> skills;

  const _SkillsUpdated(this.skills);

  @override
  List<Object> get props => [skills];
}
