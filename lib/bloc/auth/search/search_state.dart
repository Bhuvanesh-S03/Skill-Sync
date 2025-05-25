import 'package:equatable/equatable.dart';
import 'package:skillsync/models/skill_model.dart';

enum SearchStatus { initial, loading, loaded, error }

class SearchState extends Equatable {
  final SearchStatus status;
  final String query;
  final String? selectedCategory;
  final List<SkillModel> results;
  final String? errorMessage;

  const SearchState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.selectedCategory,
    this.results = const [],
    this.errorMessage,
  });

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    String? selectedCategory,
    List<SkillModel>? results,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      selectedCategory: selectedCategory,
      results: results ?? this.results,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    query,
    selectedCategory,
    results,
    errorMessage,
  ];
}
