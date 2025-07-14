// lib/screens/requests_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillsync/models/request_model.dart';
import 'package:skillsync/repositories/request_repository.dart';
import 'package:skillsync/repositories/firebase_chat.dart';
import 'package:skillsync/repositories/rating_repository.dart';
import 'package:skillsync/screens/chat_screen.dart';
import 'package:skillsync/widgets/rating_dialog.dart';

class RequestsScreen extends StatefulWidget {
  final RequestRepository requestRepository;
  final FirebaseChatService chatRepository;

  const RequestsScreen({
    super.key,
    required this.requestRepository,
    required this.chatRepository,
  });

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RatingRepository _ratingRepository = RatingRepository();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skill Swap Requests'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Received'), Tab(text: 'Sent')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildIncomingRequests(), _buildOutgoingRequests()],
      ),
    );
  }

  Widget _buildIncomingRequests() {
    return StreamBuilder<List<SkillSwapRequest>>(
      stream: widget.requestRepository.getIncomingRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No incoming requests',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return _buildIncomingRequestCard(request);
          },
        );
      },
    );
  }

  Widget _buildOutgoingRequests() {
    return StreamBuilder<List<SkillSwapRequest>>(
      stream: widget.requestRepository.getOutgoingRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.send_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No sent requests',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return _buildOutgoingRequestCard(request);
          },
        );
      },
    );
  }

  Widget _buildIncomingRequestCard(SkillSwapRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    request.requesterName.isNotEmpty
                        ? request.requesterName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
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
                        request.requesterName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatDate(request.createdAt),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(request.status),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Skill Swap Proposal:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'They offer:',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              request.requesterSkillName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.swap_horiz, color: Colors.grey),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'For your:',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              request.targetSkillName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (request.message != null) ...[
              const SizedBox(height: 12),
              Text(
                '"${request.message}"',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
              ),
            ],
            if (request.status == RequestStatus.pending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _rejectRequest(request.id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _acceptRequest(request),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ] else if (request.status == RequestStatus.accepted) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openChat(request),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FutureBuilder<bool>(
                      future: _ratingRepository.canRateSkillSwap(
                        _auth.currentUser?.uid ?? '',
                        request.id,
                      ),
                      builder: (context, snapshot) {
                        final canRate = snapshot.data ?? false;
                        return ElevatedButton.icon(
                          onPressed:
                              canRate
                                  ? () => _showRatingDialog(request)
                                  : () => _showExistingRating(request),
                          icon: Icon(canRate ? Icons.star_border : Icons.star),
                          label: Text(canRate ? 'Rate' : 'View Rating'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                canRate ? Colors.amber : Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOutgoingRequestCard(SkillSwapRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    request.targetUserName.isNotEmpty
                        ? request.targetUserName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
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
                        'To: ${request.targetUserName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatDate(request.createdAt),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(request.status),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Skill Swap Proposal:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'You offer:',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              request.requesterSkillName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.swap_horiz, color: Colors.grey),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'For their:',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              request.targetSkillName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (request.message != null) ...[
              const SizedBox(height: 12),
              Text(
                '"${request.message}"',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
              ),
            ],
            if (request.status == RequestStatus.accepted) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openChat(request),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FutureBuilder<bool>(
                      future: _ratingRepository.canRateSkillSwap(
                        _auth.currentUser?.uid ?? '',
                        request.id,
                      ),
                      builder: (context, snapshot) {
                        final canRate = snapshot.data ?? false;
                        return ElevatedButton.icon(
                          onPressed:
                              canRate
                                  ? () => _showRatingDialog(request)
                                  : () => _showExistingRating(request),
                          icon: Icon(canRate ? Icons.star_border : Icons.star),
                          label: Text(canRate ? 'Rate' : 'View Rating'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                canRate ? Colors.amber : Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(RequestStatus status) {
    Color color;
    String text;

    switch (status) {
      case RequestStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        break;
      case RequestStatus.accepted:
        color = Colors.green;
        text = 'Accepted';
        break;
      case RequestStatus.rejected:
        color = Colors.red;
        text = 'Rejected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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

  Future<void> _acceptRequest(SkillSwapRequest request) async {
    try {
      await widget.requestRepository.acceptRequest(request.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request accepted! You can now chat.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting request: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectRequest(String requestId) async {
    try {
      await widget.requestRepository.rejectRequest(requestId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request declined.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error declining request: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openChat(SkillSwapRequest request) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final otherUserId =
          currentUser.uid == request.requesterId
              ? request.targetUserId
              : request.requesterId;
      final otherUserName =
          currentUser.uid == request.requesterId
              ? request.targetUserName
              : request.requesterName;

      final chatRoomId = await widget.chatRepository.createOrGetChatRoom(
        otherUserId: otherUserId,
        otherUserName: otherUserName,
        skillName: '${request.requesterSkillName} ↔ ${request.targetSkillName}',
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ChatScreen(
                  chatRepository: widget.chatRepository,
                  chatRoomId: chatRoomId,
                  currentUserId: currentUser.uid,
                  otherUserName: otherUserName,
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

  Future<void> _showRatingDialog(SkillSwapRequest request) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final otherUserId =
        currentUser.uid == request.requesterId
            ? request.targetUserId
            : request.requesterId;
    final otherUserName =
        currentUser.uid == request.requesterId
            ? request.targetUserName
            : request.requesterName;

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => RatingDialog(
            skillSwapId: request.id,
            ratedUserId: otherUserId,
            ratedUserName: otherUserName,
            skillName:
                '${request.requesterSkillName} ↔ ${request.targetSkillName}',
            ratingRepository: _ratingRepository,
          ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rating submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _showExistingRating(SkillSwapRequest request) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      final rating = await _ratingRepository.getRatingForSkillSwap(
        currentUser.uid,
        request.id,
      );

      if (rating != null && mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Your Rating'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < rating.rating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 24,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          rating.rating.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    if (rating.comment != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Comment: "${rating.comment}"',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      'Rated on: ${_formatDate(rating.createdAt)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
                      _editRating(request, rating);
                    },
                    child: const Text('Edit'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading rating: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _editRating(SkillSwapRequest request, rating) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final otherUserId =
        currentUser.uid == request.requesterId
            ? request.targetUserId
            : request.requesterId;
    final otherUserName =
        currentUser.uid == request.requesterId
            ? request.targetUserName
            : request.requesterName;

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => RatingDialog(
            skillSwapId: request.id,
            ratedUserId: otherUserId,
            ratedUserName: otherUserName,
            skillName:
                '${request.requesterSkillName} ↔ ${request.targetSkillName}',
            ratingRepository: _ratingRepository,
            existingRating: rating,
          ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rating updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
