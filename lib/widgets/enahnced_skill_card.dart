// lib/widgets/enhanced_skill_card.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillsync/models/skill_model.dart';
import 'package:skillsync/repositories/request_repository.dart';
import 'package:skillsync/repositories/firebase_chat.dart';
import 'package:skillsync/screens/chat_screen.dart';

class EnhancedSkillCard extends StatefulWidget {
  final SkillModel skill;
  final RequestRepository requestRepository;
  final FirebaseChatService chatRepository;
  final List<SkillModel> currentUserSkills;

  const EnhancedSkillCard({
    super.key,
    required this.skill,
    required this.requestRepository,
    required this.chatRepository,
    required this.currentUserSkills,
  });

  @override
  State<EnhancedSkillCard> createState() => _EnhancedSkillCardState();
}

class _EnhancedSkillCardState extends State<EnhancedSkillCard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _canChat = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkChatPermission();
  }

  Future<void> _checkChatPermission() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final canChat = await widget.requestRepository.canUsersChat(
      currentUser.uid,
      widget.skill.userId,
    );

    if (mounted) {
      setState(() {
        _canChat = canChat;
      });
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showSkillSwapDialog() {
    if (widget.currentUserSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You need to add your skills first to make a swap request!',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Swap Skills with ${widget.skill.userName}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('They offer: ${widget.skill.name}'),
                const SizedBox(height: 16),
                const Text('Your skill to offer:'),
                const SizedBox(height: 8),
                DropdownButtonFormField<SkillModel>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select your skill',
                  ),
                  items:
                      widget.currentUserSkills
                          .map(
                            (skill) => DropdownMenuItem(
                              value: skill,
                              child: Text(skill.name),
                            ),
                          )
                          .toList(),
                  onChanged: (selectedSkill) {
                    if (selectedSkill != null) {
                      Navigator.of(context).pop();
                      _sendSkillSwapRequest(selectedSkill);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  Future<void> _sendSkillSwapRequest(SkillModel mySkill) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.requestRepository.sendSkillSwapRequest(
        targetUserId: widget.skill.userId,
        targetUserName: widget.skill.userName,
        targetSkillId: widget.skill.id,
        targetSkillName: widget.skill.name,
        requesterSkillId: mySkill.id,
        requesterSkillName: mySkill.name,
        message: 'I would like to swap skills with you!',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Skill swap request sent!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openChatScreen() async {
    try {
      final chatRoomId = await widget.chatRepository.createOrGetChatRoom(
        otherUserId: widget.skill.userId,
        otherUserName: widget.skill.userName,
        skillName: widget.skill.name,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ChatScreen(
                  chatRepository: widget.chatRepository,
                  chatRoomId: chatRoomId,
                  currentUserId: _auth.currentUser!.uid,
                  otherUserName: widget.skill.userName,
                ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening chat: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;
    final isOwnSkill = currentUser?.uid == widget.skill.userId;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(
                      widget.skill.category,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.skill.category,
                    style: TextStyle(
                      color: _getCategoryColor(widget.skill.category),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(widget.skill.createdAt),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.skill.name,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.skill.description,
              style: TextStyle(color: Colors.grey[700], height: 1.5),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    widget.skill.userName.isNotEmpty
                        ? widget.skill.userName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.skill.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        widget.skill.name,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                if (!isOwnSkill) ...[
                  if (_canChat)
                    ElevatedButton.icon(
                      onPressed: _openChatScreen,
                      icon: const Icon(Icons.chat_bubble_outline, size: 18),
                      label: const Text('Chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _showSkillSwapDialog,
                      icon:
                          _isLoading
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.swap_horiz, size: 18),
                      label: Text(_isLoading ? 'Sending...' : 'Request Swap'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
