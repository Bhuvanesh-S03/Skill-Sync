// lib/repositories/request_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillsync/models/request_model.dart';
import 'package:skillsync/models/skill_model.dart';

class RequestRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Send a skill swap request
  Future<void> sendSkillSwapRequest({
    required String targetUserId,
    required String targetUserName,
    required String targetSkillId,
    required String targetSkillName,
    required String requesterSkillId,
    required String requesterSkillName,
    String? message,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    // Check if request already exists
    final existingRequest =
        await _firestore
            .collection('skill_requests')
            .where('requesterId', isEqualTo: currentUser.uid)
            .where('targetUserId', isEqualTo: targetUserId)
            .where('targetSkillId', isEqualTo: targetSkillId)
            .where('requesterSkillId', isEqualTo: requesterSkillId)
            .where('status', isEqualTo: 'pending')
            .get();

    if (existingRequest.docs.isNotEmpty) {
      throw Exception('Request already sent for this skill swap');
    }

    final request = SkillSwapRequest(
      id: '',
      requesterId: currentUser.uid,
      requesterName: currentUser.displayName ?? 'Unknown',
      requesterSkillId: requesterSkillId,
      requesterSkillName: requesterSkillName,
      targetUserId: targetUserId,
      targetUserName: targetUserName,
      targetSkillId: targetSkillId,
      targetSkillName: targetSkillName,
      status: RequestStatus.pending,
      createdAt: DateTime.now(),
      message: message,
    );

    await _firestore.collection('skill_requests').add(request.toFirestore());
  }

  // Get incoming requests (requests sent to current user)
  Stream<List<SkillSwapRequest>> getIncomingRequests() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('skill_requests')
        .where('targetUserId', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => SkillSwapRequest.fromFirestore(doc))
                  .toList(),
        );
  }

  // Get outgoing requests (requests sent by current user)
  Stream<List<SkillSwapRequest>> getOutgoingRequests() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('skill_requests')
        .where('requesterId', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => SkillSwapRequest.fromFirestore(doc))
                  .toList(),
        );
  }

  // Accept a skill swap request
  Future<void> acceptRequest(String requestId) async {
    await _firestore.collection('skill_requests').doc(requestId).update({
      'status': 'accepted',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Reject a skill swap request
  Future<void> rejectRequest(String requestId) async {
    await _firestore.collection('skill_requests').doc(requestId).update({
      'status': 'rejected',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get user's skills for request selection
  Stream<List<SkillModel>> getUserSkills(String userId) {
    return _firestore
        .collection('skills')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => SkillModel.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Check if users can chat (have accepted request)
  Future<bool> canUsersChat(String userId1, String userId2) async {
    final acceptedRequests =
        await _firestore
            .collection('skill_requests')
            .where('status', isEqualTo: 'accepted')
            .get();

    return acceptedRequests.docs.any((doc) {
      final data = doc.data();
      return (data['requesterId'] == userId1 &&
              data['targetUserId'] == userId2) ||
          (data['requesterId'] == userId2 && data['targetUserId'] == userId1);
    });
  }
}
