import 'package:flutter/material.dart';

class CategoryChips extends StatelessWidget {
  final String? selectedCategory;
  final Function(String?) onCategorySelected;

  const CategoryChips({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const List<String> categories = [
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
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // "All" chip
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: selectedCategory == null,
                    onSelected: (selected) {
                      onCategorySelected(selected ? null : selectedCategory);
                    },
                    backgroundColor: Colors.grey[100],
                    selectedColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).colorScheme.primary,
                    labelStyle: TextStyle(
                      color:
                          selectedCategory == null
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[700],
                      fontWeight:
                          selectedCategory == null
                              ? FontWeight.bold
                              : FontWeight.normal,
                    ),
                  ),
                ),
                // Category chips
                ...categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getCategoryIcon(category),
                            size: 16,
                            color:
                                selectedCategory == category
                                    ? Theme.of(context).colorScheme.primary
                                    : _getCategoryColor(category),
                          ),
                          const SizedBox(width: 4),
                          Text(category),
                        ],
                      ),
                      selected: selectedCategory == category,
                      onSelected: (selected) {
                        onCategorySelected(selected ? category : null);
                      },
                      backgroundColor: Colors.grey[100],
                      selectedColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.2),
                      checkmarkColor: Theme.of(context).colorScheme.primary,
                      labelStyle: TextStyle(
                        color:
                            selectedCategory == category
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey[700],
                        fontWeight:
                            selectedCategory == category
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
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
}
