import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillsync/repositories/firebase_chat.dart';
import 'package:skillsync/screens/chat_screen.dart';

class SkillCard extends StatefulWidget {
  final String skillName;
  final String description;
  final String otherUserId;
  final String otherUserName;
  final FirebaseChatService chatRepository;

  const SkillCard({
    super.key,
    required this.skillName,
    required this.description,
    required this.otherUserId,
    required this.otherUserName,
    required this.chatRepository,
  });

  @override
  State<SkillCard> createState() => _SkillCardState();
}

class _SkillCardState extends State<SkillCard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _chatRoomId;

  @override
  void initState() {
    super.initState();
    _createOrGetChatRoom();
  }

  Future<void> _createOrGetChatRoom() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final chatRoomId = await widget.chatRepository.createOrGetChatRoom(
      otherUserId: widget.otherUserId,
      otherUserName: widget.otherUserName,
      skillName: widget.skillName,
    );

    setState(() {
      _chatRoomId = chatRoomId;
    });
  }

  void _openChatScreen(BuildContext context) {
    if (_chatRoomId == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChatScreen(
              chatRepository: widget.chatRepository,
              chatRoomId: _chatRoomId!,
              currentUserId: _auth.currentUser!.uid,
              otherUserName: widget.otherUserName,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.skillName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              widget.description,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            if (currentUser != null && currentUser.uid != widget.otherUserId)
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Chat'),
                  onPressed: () => _openChatScreen(context),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
