// Chat Models
class ChatRoom {
  final String id;
  final String connectionId;
  final String user1Id;
  final String user1Name;
  final String user2Id;
  final String user2Name;
  final String skillName;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime? lastMessageAt;

  ChatRoom({
    required this.id,
    required this.connectionId,
    required this.user1Id,
    required this.user1Name,
    required this.user2Id,
    required this.user2Name,
    required this.skillName,
    this.messages = const [],
    required this.createdAt,
    this.lastMessageAt,
  });

  String getOtherUserName(String currentUserId) {
    return currentUserId == user1Id ? user2Name : user1Name;
  }

  String getOtherUserId(String currentUserId) {
    return currentUserId == user1Id ? user2Id : user1Id;
  }
}

class ChatMessage {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });
}
