import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:skillsync/models/user_model.dart';
import 'package:skillsync/repositories/firebase_chat.dart';
import 'package:skillsync/screens/chat_screen.dart';


class ChatListScreen extends StatelessWidget {
  final FirebaseChatService chatRepository;
  final UserModel currentUser;

  const ChatListScreen({
    super.key,
    required this.chatRepository,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = currentUser.id;
    print('ChatListScreen build called. CurrentUserId: $currentUserId');

    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: StreamBuilder<QuerySnapshot>(
        stream: chatRepository.getUserChatRooms(currentUserId),
        builder: (context, snapshot) {
          print('StreamBuilder connection state: ${snapshot.connectionState}');
          if (snapshot.hasError) {
            print('Stream error: ${snapshot.error}');
            return Center(child: Text('Error loading chats'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            print('Waiting for chat rooms data...');
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            print('No chats found');
            return const Center(child: Text('No chats yet'));
          }
          if (snapshot.hasError) {
  print('Stream error: ${snapshot.error}');
  return Center(
    child: Text(
      'Error loading chats:\n${snapshot.error}',
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.red),
    ),
  );
}


          final chats = snapshot.data!.docs;
          print('Chats count: ${chats.length}');
          for (var chatDoc in chats) {
            print('Chat ID: ${chatDoc.id}, Data: ${chatDoc.data()}');
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index].data()! as Map<String, dynamic>;

              final participants = Map<String, String>.from(chat['participants'] ?? {});

              participants.remove(currentUserId);
              final otherUserName = participants.values.isNotEmpty ? participants.values.first : 'Unknown';

              return ListTile(
                title: Text(otherUserName),
                subtitle: Text(chat['skill'] ?? ''),
                trailing: Text(
                  _formatTimestamp(chat['lastMessageTime'] as Timestamp?),
                  style: const TextStyle(fontSize: 12),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatRepository: chatRepository,
                        chatRoomId: chats[index].id,
                        currentUserId: currentUserId,
                        otherUserName: otherUserName,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return DateFormat('MMM d, h:mm a').format(date);
  }
  
}
