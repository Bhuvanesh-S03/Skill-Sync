import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillsync/bloc/auth/search/search_event.dart';
import 'package:skillsync/bloc/auth/search/search_state.dart';
import 'package:skillsync/models/skill_model.dart';
import 'package:skillsync/repositories/skill_repository.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SkillRepository _skillRepository;
  StreamSubscription? _skillSubscription;

  SearchBloc({required SkillRepository skillRepository})
    : _skillRepository = skillRepository,
      super(const SearchState()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<SearchCategoryChanged>(_onSearchCategoryChanged);
    on<SearchClearRequested>(_onSearchClearRequested);
    on<SearchResultsUpdated>(_onSearchResultsUpdated);
  }

  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) {
    emit(state.copyWith(query: event.query, status: SearchStatus.loading));
    _performSearch();
  }

  void _onSearchCategoryChanged(
    SearchCategoryChanged event,
    Emitter<SearchState> emit,
  ) {
    emit(
      state.copyWith(
        selectedCategory: event.category,
        status: SearchStatus.loading,
      ),
    );
    _performSearch();
  }

  void _onSearchClearRequested(
    SearchClearRequested event,
    Emitter<SearchState> emit,
  ) {
    _skillSubscription?.cancel();
    emit(const SearchState());
  }

  void _onSearchResultsUpdated(
    SearchResultsUpdated event,
    Emitter<SearchState> emit,
  ) {
    final filteredSkills = _filterSkills(event.skills);
    emit(state.copyWith(status: SearchStatus.loaded, results: filteredSkills));
  }

  void _performSearch() {
    if (state.query.isEmpty && state.selectedCategory == null) {
      emit(state.copyWith(status: SearchStatus.initial, results: []));
      return;
    }

    _skillSubscription?.cancel();
    _skillSubscription = _skillRepository.getSkills().listen(
      (skills) => add(SearchResultsUpdated(skills)),
      onError:
          (error) => emit(
            state.copyWith(
              status: SearchStatus.error,
              errorMessage: error.toString(),
            ),
          ),
    );
  }

  List<SkillModel> _filterSkills(List<SkillModel> skills) {
    return skills.where((skill) {
      final matchesQuery =
          state.query.isEmpty ||
          skill.name.toLowerCase().contains(state.query.toLowerCase()) ||
          skill.description.toLowerCase().contains(state.query.toLowerCase()) ||
          skill.userName.toLowerCase().contains(state.query.toLowerCase());

      final matchesCategory =
          state.selectedCategory == null ||
          skill.category == state.selectedCategory;

      return matchesQuery && matchesCategory;
    }).toList();
  }

  @override
  Future<void> close() {
    _skillSubscription?.cancel();
    return super.close();
  }
}
