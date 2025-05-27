import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillsync/bloc/skill/skill_event.dart';
import 'package:skillsync/bloc/skill/skill_state.dart';
import 'package:skillsync/repositories/skill_repository.dart';

class SkillBloc extends Bloc<SkillEvent, SkillState> {
  final FirebaseSkillRepository _skillRepository;
  StreamSubscription? _skillSubscription;

  SkillBloc({required FirebaseSkillRepository skillRepository})
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
    emit(state.copyWith(status: SkillStatus.loading, clearError: true));
    _skillSubscription?.cancel();
    _skillSubscription = _skillRepository.getSkillsStream().listen(
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
        clearError: true,
      ),
    );
  }

  void _onSkillAddRequested(
    SkillAddRequested event,
    Emitter<SkillState> emit,
  ) async {
    try {
      emit(state.copyWith(status: SkillStatus.loading, clearError: true));
      await _skillRepository.addSkill(event.skill);
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
      emit(state.copyWith(status: SkillStatus.loading, clearError: true));
      await _skillRepository.deleteSkill(event.skillId);
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
