import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillsync/bloc/auth/skill/skill_bloc.dart';
import 'package:skillsync/bloc/auth/skill/skill_state.dart';
import 'package:skillsync/widgets/skill_card.dart';

class TopSkillsWidget extends StatelessWidget {
  const TopSkillsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(Icons.trending_up, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Popular Skills',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          BlocBuilder<SkillBloc, SkillState>(
            builder: (context, state) {
              if (state.status == SkillStatus.loading) {
                return const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state.status == SkillStatus.error || state.skills.isEmpty) {
                return const SizedBox(
                  height: 120,
                  child: Center(
                    child: Text(
                      'No popular skills to show',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              // Get top 3 skills (you can modify this logic based on your requirements)
              final topSkills = state.skills.take(3).toList();

              return SizedBox(
                height: 200,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: topSkills.length,
                  itemBuilder: (context, index) {
                    final skill = topSkills[index];
                    return Container(
                      width: 280,
                      margin: const EdgeInsets.only(right: 12),
                      child: SkillCard(skill: skill),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
