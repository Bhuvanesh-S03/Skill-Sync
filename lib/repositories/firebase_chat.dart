import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get stream of chat rooms for current user
  Stream<QuerySnapshot> getUserChatRooms(String userId) {
    return _firestore
        .collection('chat_rooms')
        .where('participantIds', arrayContains: userId)
        //.orderBy('lastMessageTime', descending: true) // you can enable ordering if needed
        .snapshots();
  }

  // Get messages for a specific chat room
  Stream<QuerySnapshot> getMessages(String chatRoomId) {
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Send a message
  Future<void> sendMessage({
    required String chatRoomId,
    required String text,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
          'senderId': currentUser.uid,
          'text': text,
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        });

    // Update last message in chat room
    await _firestore.collection('chat_rooms').doc(chatRoomId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  // Create or get existing chat room with validation
  Future<String> createOrGetChatRoom({
    required String otherUserId,
    required String otherUserName,
    required String skillName,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    final currentUserId = currentUser.uid;

    // Prevent creating chat with yourself
    if (currentUserId == otherUserId) {
      throw Exception("Cannot create chat room with yourself");
    }

    // Sort to ensure consistent chatRoomId and no duplicates
    final users = [currentUserId, otherUserId]..sort();

    final chatRoomId = 'chat_${users.join("_")}';

    await _firestore.collection('chat_rooms').doc(chatRoomId).set({
      'participants': {
        currentUserId: currentUser.displayName ?? 'Unknown',
        otherUserId: otherUserName.isNotEmpty ? otherUserName : 'Unknown',
      },
      'participantIds': users,
      'skill': skillName,
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return chatRoomId;  // <-- Important: return chatRoomId here
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatRoomId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    final messages = await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('senderId', isNotEqualTo: currentUserId)
        .where('read', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in messages.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }
}
