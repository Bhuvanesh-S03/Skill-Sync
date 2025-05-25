import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load requests when screen initializes
    // context.read<ConnectionBloc>().add(ConnectionLoadReceived());
    // context.read<ConnectionBloc>().add(ConnectionLoadSent());
    // context.read<ConnectionBloc>().add(ConnectionLoadAccepted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Connections',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: 'Received', icon: Icon(Icons.inbox)),
            Tab(text: 'Sent', icon: Icon(Icons.send)),
            Tab(text: 'Connected', icon: Icon(Icons.people)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReceivedRequestsTab(),
          _buildSentRequestsTab(),
          _buildConnectedTab(),
        ],
      ),
    );
  }

  Widget _buildReceivedRequestsTab() {
    // Mock data for demonstration
    final receivedRequests = [
      _MockConnectionRequest(
        id: '1',
        skillName: 'React Development',
        senderName: 'John Doe',
        message:
            'Hi! I would love to learn React from you. I have basic JavaScript knowledge.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      _MockConnectionRequest(
        id: '2',
        skillName: 'Digital Marketing',
        senderName: 'Sarah Wilson',
        message:
            'I\'m interested in learning digital marketing strategies. Can you help?',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    if (receivedRequests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inbox,
        title: 'No Received Requests',
        subtitle:
            'When people want to learn from you, their requests will appear here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: receivedRequests.length,
      itemBuilder: (context, index) {
        final request = receivedRequests[index];
        return _buildReceivedRequestCard(request);
      },
    );
  }

  Widget _buildSentRequestsTab() {
    // Mock data for demonstration
    final sentRequests = [
      _MockConnectionRequest(
        id: '1',
        skillName: 'Photography',
        senderName: 'Mike Johnson',
        message: 'I sent a request to learn photography basics.',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        status: 'pending',
      ),
    ];

    if (sentRequests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.send,
        title: 'No Sent Requests',
        subtitle:
            'Start exploring skills and send learning requests to connect with teachers.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sentRequests.length,
      itemBuilder: (context, index) {
        final request = sentRequests[index];
        return _buildSentRequestCard(request);
      },
    );
  }

  Widget _buildConnectedTab() {
    // Mock data for demonstration
    final connections = [
      _MockConnectionRequest(
        id: '1',
        skillName: 'Flutter Development',
        senderName: 'Alice Brown',
        message: 'Connected for Flutter learning',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        status: 'accepted',
      ),
    ];

    if (connections.isEmpty) {
      return _buildEmptyState(
        icon: Icons.people,
        title: 'No Connections Yet',
        subtitle:
            'Your accepted connections will appear here. Start chatting with your learning partners!',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: connections.length,
      itemBuilder: (context, index) {
        final connection = connections[index];
        return _buildConnectionCard(connection);
      },
    );
  }

  Widget _buildReceivedRequestCard(_MockConnectionRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    request.senderName[0].toUpperCase(),
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
                        request.senderName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Wants to learn: ${request.skillName}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatTime(request.createdAt),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                request.message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
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
                    onPressed: () => _acceptRequest(request.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentRequestCard(_MockConnectionRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.school,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.skillName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Request to: ${request.senderName}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(request.status ?? 'pending'),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Sent ${_formatTime(request.createdAt)}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionCard(_MockConnectionRequest connection) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                connection.senderName[0].toUpperCase(),
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
                    connection.senderName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    connection.skillName,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  Text(
                    'Connected ${_formatTime(connection.createdAt)}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _openChat(connection),
              icon: const Icon(Icons.chat, size: 16),
              label: const Text('Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status.toLowerCase()) {
      case 'accepted':
        color = Colors.green;
        text = 'Accepted';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Declined';
        break;
      default:
        color = Colors.orange;
        text = 'Pending';
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

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _acceptRequest(String requestId) {
    // context.read<ConnectionBloc>().add(ConnectionAcceptRequest(requestId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request accepted! You can now chat with this person.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejectRequest(String requestId) {
    // context.read<ConnectionBloc>().add(ConnectionRejectRequest(requestId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request declined.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _openChat(_MockConnectionRequest connection) {
    // Navigate to chat screen
    Navigator.of(context).pushNamed(
      '/chat',
      arguments: {
        'chatRoomId': connection.id,
        'otherUserName': connection.senderName,
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// Mock class for demonstration
class _MockConnectionRequest {
  final String id;
  final String skillName;
  final String senderName;
  final String message;
  final DateTime createdAt;
  final String? status;

  _MockConnectionRequest({
    required this.id,
    required this.skillName,
    required this.senderName,
    required this.message,
    required this.createdAt,
    this.status,
  });
}
