// models/chat_room.dart
import 'package:equatable/equatable.dart';

class ChatRoom extends Equatable {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSenderId;
  final DateTime createdAt;
  final int unreadCount;

  const ChatRoom({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderId,
    required this.createdAt,
    this.unreadCount = 0,
  });

  factory ChatRoom.fromMap(Map<String, dynamic> map, String id) {
    return ChatRoom(
      id: id,
      participantIds: List<String>.from(map['participantIds'] ?? []),
      participantNames: Map<String, String>.from(map['participantNames'] ?? {}),
      lastMessage: map['lastMessage'],
      lastMessageTime:
          map['lastMessageTime'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['lastMessageTime'])
              : null,
      lastMessageSenderId: map['lastMessageSenderId'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      unreadCount: map['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participantIds': participantIds,
      'participantNames': participantNames,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.millisecondsSinceEpoch,
      'lastMessageSenderId': lastMessageSenderId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'unreadCount': unreadCount,
    };
  }

  String getOtherParticipantName(String currentUserId) {
    final otherParticipantId = participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    return participantNames[otherParticipantId] ?? 'Unknown User';
  }

  String getOtherParticipantId(String currentUserId) {
    return participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  ChatRoom copyWith({
    String? id,
    List<String>? participantIds,
    Map<String, String>? participantNames,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastMessageSenderId,
    DateTime? createdAt,
    int? unreadCount,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      participantNames: participantNames ?? this.participantNames,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      createdAt: createdAt ?? this.createdAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [
    id,
    participantIds,
    participantNames,
    lastMessage,
    lastMessageTime,
    lastMessageSenderId,
    createdAt,
    unreadCount,
  ];
}
