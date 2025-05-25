// Chat Events
abstract class ChatEvent {}

class ChatLoadRooms extends ChatEvent {}

class ChatLoadMessages extends ChatEvent {
  final String chatRoomId;

  ChatLoadMessages(this.chatRoomId);
}

class ChatSendMessage extends ChatEvent {
  final String chatRoomId;
  final String content;

  ChatSendMessage({required this.chatRoomId, required this.content});
}

class ChatMarkAsRead extends ChatEvent {
  final String chatRoomId;

  ChatMarkAsRead(this.chatRoomId);
}
