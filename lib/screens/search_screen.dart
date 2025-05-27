import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillsync/bloc/search/search_bloc.dart';
import 'package:skillsync/bloc/search/search_event.dart';
import 'package:skillsync/bloc/search/search_state.dart';
import 'package:skillsync/models/skill_model.dart'; // <-- Import your SkillModel
import 'package:skillsync/repositories/firebase_chat.dart';
import 'package:skillsync/widgets/skill_card.dart' show SkillCard;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String? _selectedCategory;

  final List<String> _categories = [
    'All Categories',
    'Technology',
    'Design',
    'Business',
    'Marketing',
    'Education',
    'Arts',
    'Music',
    'Sports',
    'Cooking',
    'Languages',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Search Skills',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search TextField
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search skills, teachers, or descriptions...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                context.read<SearchBloc>().add(
                                  const SearchQueryChanged(''),
                                );
                              },
                            )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: (query) {
                    context.read<SearchBloc>().add(SearchQueryChanged(query));
                  },
                ),
                const SizedBox(height: 16),
                // Category Filter
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[50],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory ?? 'All Categories',
                      hint: const Text('Select Category'),
                      isExpanded: true,
                      items:
                          _categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Row(
                                children: [
                                  Icon(
                                    _getCategoryIcon(category),
                                    size: 20,
                                    color: _getCategoryColor(category),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(category),
                                ],
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                        final category =
                            value == 'All Categories' ? null : value;
                        context.read<SearchBloc>().add(
                          SearchCategoryChanged(category),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Search Results
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state.status == SearchStatus.initial) {
                  return _buildInitialState();
                }
                if (state.status == SearchStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == SearchStatus.error) {
                  return _buildErrorState(state.errorMessage);
                }
                if (state.results == null || state.results.isEmpty) {
                  return _buildEmptyState(state.query);
                }
                return _buildResults(state.results);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Search for Skills',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Find skills you want to learn or teachers to connect with',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String? errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Search Error',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(errorMessage ?? 'Something went wrong'),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Skills Found',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            query.isNotEmpty
                ? 'No skills match "$query"'
                : 'No skills match your filters',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Changed here: accept List<SkillModel> instead of List<Map<String, dynamic>>
 Widget _buildResults(List<SkillModel> results) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final skill = results[index];
        return SkillCard(
          skillName: skill.name,
          description: skill.description,
          otherUserId: skill.userId,
          otherUserName: skill.userName, chatRepository: FirebaseChatService(),
        );
      },
    );
  }


  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'technology':
        return Icons.computer;
      case 'design':
        return Icons.palette;
      case 'business':
        return Icons.business;
      case 'marketing':
        return Icons.campaign;
      case 'education':
        return Icons.school;
      case 'arts':
        return Icons.brush;
      case 'music':
        return Icons.music_note;
      case 'sports':
        return Icons.sports;
      case 'cooking':
        return Icons.restaurant;
      case 'languages':
        return Icons.language;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'technology':
        return Colors.blue;
      case 'design':
        return Colors.purple;
      case 'business':
        return Colors.orange;
      case 'marketing':
        return Colors.green;
      case 'education':
        return Colors.teal;
      case 'arts':
        return Colors.pink;
      case 'music':
        return Colors.deepPurple;
      case 'sports':
        return Colors.red;
      case 'cooking':
        return Colors.amber;
      case 'languages':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
