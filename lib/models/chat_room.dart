import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ChatRoom extends Equatable {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final Map<String, String?>? participantProfileImages;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSenderId;
  final String? skillId;
  final String? skillName;
  final DateTime createdAt;
  final int unreadCount;
  final Map<String, bool>? typingStatus;

  const ChatRoom({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    this.participantProfileImages,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderId,
    this.skillId,
    this.skillName,
    required this.createdAt,
    this.unreadCount = 0,
    this.typingStatus,
  });

  factory ChatRoom.fromMap(Map<String, dynamic> map, String id) {
    return ChatRoom(
      id: id,
      participantIds: List<String>.from(map['participantIds'] ?? []),
      participantNames: Map<String, String>.from(map['participantNames'] ?? {}),
      participantProfileImages:
          map['participantProfileImages'] != null
              ? Map<String, String?>.from(map['participantProfileImages'])
              : null,
      lastMessage: map['lastMessage'],
      lastMessageTime:
          map['lastMessageTime'] != null
              ? (map['lastMessageTime'] as Timestamp).toDate()
              : null,
      lastMessageSenderId: map['lastMessageSenderId'],
      skillId: map['skillId'],
      skillName: map['skillName'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      unreadCount: map['unreadCount'] ?? 0,
      typingStatus:
          map['typing'] != null ? Map<String, bool>.from(map['typing']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participantIds': participantIds,
      'participantNames': participantNames,
      if (participantProfileImages != null)
        'participantProfileImages': participantProfileImages,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'lastMessageSenderId': lastMessageSenderId,
      if (skillId != null) 'skillId': skillId,
      if (skillName != null) 'skillName': skillName,
      'createdAt': createdAt,
      'unreadCount': unreadCount,
      if (typingStatus != null) 'typing': typingStatus,
    };
  }

  String getOtherParticipantId(String currentUserId) {
    return participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  bool isTyping(String userId) {
    return typingStatus?[userId] ?? false;
  }

  @override
  List<Object?> get props => [
    id,
    participantIds,
    participantNames,
    participantProfileImages,
    lastMessage,
    lastMessageTime,
    lastMessageSenderId,
    skillId,
    skillName,
    createdAt,
    unreadCount,
    typingStatus,
  ];
  // Add this to your ChatRoom model
  ChatRoom copyWith({
    String? id,
    List<String>? participantIds,
    Map<String, String>? participantNames,
    Map<String, String?>? participantProfileImages,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastMessageSenderId,
    String? skillId,
    String? skillName,
    DateTime? createdAt,
    int? unreadCount,
    Map<String, bool>? typingStatus,
    String? otherUserName, // New
    String? otherUserProfileImage, // New
  }) {
    return ChatRoom(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      participantNames: participantNames ?? this.participantNames,
      participantProfileImages:
          participantProfileImages ?? this.participantProfileImages,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      skillId: skillId ?? this.skillId,
      skillName: skillName ?? this.skillName,
      createdAt: createdAt ?? this.createdAt,
      unreadCount: unreadCount ?? this.unreadCount,
      typingStatus: typingStatus ?? this.typingStatus,
    );
  }
}
