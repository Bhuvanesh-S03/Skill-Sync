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
    on<SkillsUpdated>(_onSkillsUpdated);
  }

  void _onSkillLoadRequested(
    SkillLoadRequested event,
    Emitter<SkillState> emit,
  ) {
    emit(state.copyWith(status: SkillStatus.loading));
    _skillSubscription?.cancel();
    _skillSubscription = _skillRepository.getSkills().listen(
      (skills) => add(SkillsUpdated(skills)),
      onError:
          (error) => emit(
            state.copyWith(
              status: SkillStatus.error,
              errorMessage: error.toString(),
            ),
          ),
    );
  }

  void _onSkillsUpdated(SkillsUpdated event, Emitter<SkillState> emit) {
    emit(
      state.copyWith(
        status: SkillStatus.loaded,
        skills: event.skills,
        errorMessage: null,
      ),
    );
  }

  void _onSkillAddRequested(
    SkillAddRequested event,
    Emitter<SkillState> emit,
  ) async {
    try {
      emit(state.copyWith(status: SkillStatus.loading));
      await _skillRepository.addSkill(event.skill);
      // Stream will update automatically
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
      // Stream will update automatically
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
