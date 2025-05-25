import 'package:equatable/equatable.dart';
import 'package:skillsync/models/skill_model.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object> get props => [query];
}

class SearchCategoryChanged extends SearchEvent {
  final String? category;

  const SearchCategoryChanged(this.category);

  @override
  List<Object?> get props => [category];
}

class SearchClearRequested extends SearchEvent {
  const SearchClearRequested();
}

// Add the missing _SearchResultsUpdated event
class SearchResultsUpdated extends SearchEvent {
  final List<SkillModel> skills;

  const SearchResultsUpdated(this.skills);

  @override
  List<Object> get props => [skills];
}
