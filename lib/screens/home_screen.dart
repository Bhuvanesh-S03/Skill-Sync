import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillsync/bloc/auth/auth_bloc.dart';
import 'package:skillsync/bloc/auth/auth_event.dart';
import 'package:skillsync/bloc/auth/auth_state.dart';
import 'package:skillsync/bloc/auth/skill/skill_bloc.dart';
import 'package:skillsync/bloc/auth/skill/skill_event.dart';
import 'package:skillsync/bloc/auth/skill/skill_state.dart';
import 'package:skillsync/screens/add_skill_screen.dart';
import 'package:skillsync/screens/auth_screen.dart';
import 'package:skillsync/widgets/skill_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                        PopupMenuItem<String>(
                          value: 'logout',
                          child: const ListTile(
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
        body: BlocBuilder<SkillBloc, SkillState>(
          builder: (context, state) {
            if (state.status == SkillStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == SkillStatus.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading skills',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(state.errorMessage ?? 'Unknown error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<SkillBloc>().add(SkillLoadRequested());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state.skills.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No skills yet',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Be the first to share a skill!',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<SkillBloc>().add(SkillLoadRequested());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.skills.length,
                itemBuilder: (context, index) {
                  return SkillCard(skill: state.skills[index]);
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AddSkillScreen()));
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Add Skill',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
