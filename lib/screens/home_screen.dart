import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillsync/bloc/auth/auth_bloc.dart';
import 'package:skillsync/bloc/auth/auth_event.dart';
import 'package:skillsync/bloc/auth/auth_status.dart';
import 'package:skillsync/bloc/auth/search/search_bloc.dart';
import 'package:skillsync/bloc/auth/skill/skill_bloc.dart';
import 'package:skillsync/bloc/auth/skill/skill_event.dart';
import 'package:skillsync/bloc/auth/skill/skill_state.dart';
import 'package:skillsync/repositories/firebase_chat.dart';

import 'package:skillsync/screens/add_skill_screen.dart';
import 'package:skillsync/screens/auth_screen.dart';
import 'package:skillsync/screens/chat_list_screeen.dart';
import 'package:skillsync/screens/chat_screen.dart';
import 'package:skillsync/screens/search_screen.dart';

import 'package:skillsync/widgets/category.dart';
import 'package:skillsync/widgets/skill_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    context.read<SkillBloc>().add(SkillLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AuthScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'Skill Sync',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            // Search Button
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (_) => BlocProvider(
                          create:
                              (context) =>
                                  SearchBloc(skillRepository: context.read()),
                          child: const SearchScreen(),
                        ),
                  ),
                );
              },
            ),
            // Chat List Button
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                return IconButton(
                  icon: const Icon(Icons.chat),
                  onPressed: () {
                    if (authState.user != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (_) => ChatListScreen(
                                currentUser: authState.user!,
                                chatRepository: FirebaseChatService(),
       
                              ),

                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please log in to access chats'),
                        ),
                      );
                    }
                  },
                );
              },
            ),

            // User Profile Menu
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return PopupMenuButton<String>(
                  icon: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      state.user?.name.isNotEmpty == true
                          ? state.user!.name[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onSelected: (value) {
                    if (value == 'logout') {
                      context.read<AuthBloc>().add(AuthSignOutRequested());
                    } else if (value == 'profile') {
                      _showProfileDialog(context, state.user);
                    }
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem<String>(
                          value: 'profile',
                          child: ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(state.user?.name ?? 'User'),
                            subtitle: Text(state.user?.email ?? ''),
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem<String>(
                          value: 'settings',
                          child: ListTile(
                            leading: Icon(Icons.settings),
                            title: Text('Settings'),
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem<String>(
                          value: 'logout',
                          child: ListTile(
                            leading: Icon(Icons.logout, color: Colors.red),
                            title: Text(
                              'Sign Out',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                );
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            context.read<SkillBloc>().add(SkillLoadRequested());
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back,',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  state.user?.name ?? 'User',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Discover and share amazing skills!',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.lightbulb,
                              color: Theme.of(context).colorScheme.primary,
                              size: 32,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Category Filter
                CategoryChips(
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                    context.read<SkillBloc>().add(SkillLoadRequested());
                  },
                ),
                const SizedBox(height: 16),
                // Skills List Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        _selectedCategory == null
                            ? 'All Skills'
                            : '$_selectedCategory Skills',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (_) => BlocProvider(
                                    create:
                                        (context) => SearchBloc(
                                          skillRepository: context.read(),
                                        ),
                                    child: const SearchScreen(),
                                  ),
                            ),
                          );
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                ),
                // Skills Content
                BlocBuilder<SkillBloc, SkillState>(
                  builder: (context, state) {
                    if (state.status == SkillStatus.loading) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (state.status == SkillStatus.error) {
                      return Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(
                                Icons.error,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading skills',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(state.errorMessage ?? 'Unknown error'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<SkillBloc>().add(
                                    SkillLoadRequested(),
                                  );
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    final skills =
                        _selectedCategory == null
                            ? state.skills
                            : state.skills
                                .where(
                                  (skill) =>
                                      skill.category == _selectedCategory,
                                )
                                .toList();
                    if (skills.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.inbox,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _selectedCategory == null
                                    ? 'No skills available'
                                    : 'No skills in $_selectedCategory category',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Be the first to share a skill!',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const AddSkillScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add Skill'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: skills.length,
                      itemBuilder: (context, index) {
                        final skill = skills[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SkillCard(
                            skillName: skill.name,
                            description: skill.description,
                            otherUserId: skill.userId,
                            otherUserName: skill.userName, chatRepository: FirebaseChatService(),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 100), // Bottom padding for FAB
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AddSkillScreen()));
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context, dynamic user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Profile'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        user?.name?.isNotEmpty == true
                            ? user!.name[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'User',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user?.email ?? '',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.school),
                  title: const Text('My Skills'),
                  subtitle: const Text('Manage your shared skills'),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.of(context).pop();
                    // Navigate to user's skills
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.favorite),
                  title: const Text('Saved Skills'),
                  subtitle: const Text('View your bookmarked skills'),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.of(context).pop();
                    // Navigate to saved skills
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate to edit profile
                },
                child: const Text('Edit Profile'),
              ),
            ],
          ),
    );
  }
}
