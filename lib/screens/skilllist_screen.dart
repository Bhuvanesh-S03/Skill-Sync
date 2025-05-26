import 'package:flutter/material.dart';
import 'package:skillsync/models/skill_model.dart';
import 'package:skillsync/widgets/skill_card.dart';
import 'package:skillsync/repositories/firebase_chat.dart';

class SkillsListScreen extends StatelessWidget {
  final List<SkillModel> skills;
  final FirebaseChatService chatRepository;

  const SkillsListScreen({
    super.key,
    required this.skills,
    required this.chatRepository,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Skills')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: skills.length,
        itemBuilder: (context, index) {
          final skill = skills[index];
          return SkillCard(
            skillName: skill.name,
            description: skill.description,
            otherUserId: skill.userId,
            otherUserName: skill.userName,
            chatRepository: chatRepository,
          );
        },
      ),
    );
  }
}
