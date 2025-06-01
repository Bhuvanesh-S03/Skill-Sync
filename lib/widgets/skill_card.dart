// lib/widgets/skill_card.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillsync/models/skill_model.dart';
import 'package:skillsync/repositories/request_repository.dart';
import 'package:skillsync/repositories/firebase_chat.dart';
import 'package:skillsync/screens/chat_screen.dart';

class SkillCard extends StatefulWidget {
  final String skillName;
  final String description;
  final String otherUserId;
  final String otherUserName;
  final FirebaseChatService chatRepository;

  // Enhanced features - optional parameters to maintain compatibility
  final String? category;
  final DateTime? createdAt;
  final String? skillId;
  final RequestRepository? requestRepository;
  final List<SkillModel>? currentUserSkills;
  final VoidCallback? onDelete; // Add delete callback

  const SkillCard({
    super.key,
    required this.skillName,
    required this.description,
    required this.otherUserId,
    required this.otherUserName,
    required this.chatRepository,
    this.category,
    this.createdAt,
    this.skillId,
    this.requestRepository,
    this.currentUserSkills,
    this.onDelete, // Add delete parameter
  });

  @override
  State<SkillCard> createState() => _SkillCardState();
}

class _SkillCardState extends State<SkillCard> {
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
    if (currentUser == null || widget.requestRepository == null) {
      // If no request repository, assume chat is allowed (backward compatibility)
      setState(() {
        _canChat = true;
      });
      return;
    }

    final canChat = await widget.requestRepository!.canUsersChat(
      currentUser.uid,
      widget.otherUserId,
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

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Skill'),
            content: Text(
              'Are you sure you want to delete "${widget.skillName}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onDelete?.call();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _showSkillSwapDialog() {
    if (widget.currentUserSkills?.isEmpty ?? true) {
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
            title: Text('Swap Skills with ${widget.otherUserName}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('They offer: ${widget.skillName}'),
                const SizedBox(height: 16),
                const Text('Your skill to offer:'),
                const SizedBox(height: 8),
                DropdownButtonFormField<SkillModel>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select your skill',
                  ),
                  items:
                      widget.currentUserSkills!
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
    if (widget.requestRepository == null || widget.skillId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.requestRepository!.sendSkillSwapRequest(
        targetUserId: widget.otherUserId,
        targetUserName: widget.otherUserName,
        targetSkillId: widget.skillId!,
        targetSkillName: widget.skillName,
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
        otherUserId: widget.otherUserId,
        otherUserName: widget.otherUserName,
        skillName: widget.skillName,
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
                  otherUserName: widget.otherUserName,
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
    final isOwnSkill = currentUser?.uid == widget.otherUserId;
    final hasSwapFeatures =
        widget.requestRepository != null &&
        widget.skillId != null &&
        widget.currentUserSkills != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category, date, and delete icon row
            Row(
              children: [
                // Category chip
                if (widget.category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(
                        widget.category!,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.category!,
                      style: TextStyle(
                        color: _getCategoryColor(widget.category!),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const Spacer(),
                // Date text
                if (widget.createdAt != null)
                  Text(
                    _formatDate(widget.createdAt!),
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                // Spacing between date and delete icon
                if (widget.createdAt != null &&
                    isOwnSkill &&
                    widget.onDelete != null)
                  const SizedBox(width: 12),
                // Delete icon - only show for own skills
                if (isOwnSkill && widget.onDelete != null)
                  InkWell(
                    onTap: _showDeleteConfirmation,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.red[400],
                        size: 22, // Made icon bigger
                      ),
                    ),
                  ),
              ],
            ),

            // Add some spacing if we have top row elements
            if (widget.category != null ||
                widget.createdAt != null ||
                (isOwnSkill && widget.onDelete != null))
              const SizedBox(
                height: 16,
              ), // Increased spacing to push content down
            // Skill name
            Text(
              widget.skillName,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              widget.description,
              style: TextStyle(color: Colors.grey[700], height: 1.5),
            ),
            const SizedBox(height: 16),

            // User info and action buttons
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    widget.otherUserName.isNotEmpty
                        ? widget.otherUserName[0].toUpperCase()
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
                        widget.otherUserName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        widget.skillName,
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
                  else if (hasSwapFeatures)
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
                    )
                  else
                    // Fallback to chat button if no swap features
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
