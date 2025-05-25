// Chat State
class ChatState {
  final List<ChatRoom> chatRooms;
  final Map<String, List<ChatMessage>> messages;
  final bool isLoading;
  final String? errorMessage;
  final String? selectedChatRoomId;

  const ChatState({
    this.chatRooms = const [],
    this.messages = const {},
    this.isLoading = false,
    this.errorMessage,
    this.selectedChatRoomId,
  });

  ChatState copyWith({
    List<ChatRoom>? chatRooms,
    Map<String, List<ChatMessage>>? messages,
    bool? isLoading,
    String? errorMessage,
    String? selectedChatRoomId,
  }) {
    return ChatState(
      chatRooms: chatRooms ?? this.chatRooms,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedChatRoomId: selectedChatRoomId ?? this.selectedChatRoomId,
    );
  }

  List<ChatMessage> getMessagesForRoom(String chatRoomId) {
    return messages[chatRoomId] ?? [];
  }
}
