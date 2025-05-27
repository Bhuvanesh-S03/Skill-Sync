// lib/models/request_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum RequestStatus { pending, accepted, rejected }

class SkillSwapRequest extends Equatable {
  final String id;
  final String requesterId;
  final String requesterName;
  final String requesterSkillId;
  final String requesterSkillName;
  final String targetUserId;
  final String targetUserName;
  final String targetSkillId;
  final String targetSkillName;
  final RequestStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? message;

  const SkillSwapRequest({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    required this.requesterSkillId,
    required this.requesterSkillName,
    required this.targetUserId,
    required this.targetUserName,
    required this.targetSkillId,
    required this.targetSkillName,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.message,
  });

  factory SkillSwapRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SkillSwapRequest(
      id: doc.id,
      requesterId: data['requesterId'] ?? '',
      requesterName: data['requesterName'] ?? '',
      requesterSkillId: data['requesterSkillId'] ?? '',
      requesterSkillName: data['requesterSkillName'] ?? '',
      targetUserId: data['targetUserId'] ?? '',
      targetUserName: data['targetUserName'] ?? '',
      targetSkillId: data['targetSkillId'] ?? '',
      targetSkillName: data['targetSkillName'] ?? '',
      status: RequestStatus.values.firstWhere(
        (e) => e.toString() == 'RequestStatus.${data['status']}',
        orElse: () => RequestStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt:
          data['updatedAt'] != null
              ? (data['updatedAt'] as Timestamp).toDate()
              : null,
      message: data['message'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'requesterId': requesterId,
      'requesterName': requesterName,
      'requesterSkillId': requesterSkillId,
      'requesterSkillName': requesterSkillName,
      'targetUserId': targetUserId,
      'targetUserName': targetUserName,
      'targetSkillId': targetSkillId,
      'targetSkillName': targetSkillName,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'message': message,
    };
  }

  SkillSwapRequest copyWith({
    String? id,
    String? requesterId,
    String? requesterName,
    String? requesterSkillId,
    String? requesterSkillName,
    String? targetUserId,
    String? targetUserName,
    String? targetSkillId,
    String? targetSkillName,
    RequestStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? message,
  }) {
    return SkillSwapRequest(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      requesterName: requesterName ?? this.requesterName,
      requesterSkillId: requesterSkillId ?? this.requesterSkillId,
      requesterSkillName: requesterSkillName ?? this.requesterSkillName,
      targetUserId: targetUserId ?? this.targetUserId,
      targetUserName: targetUserName ?? this.targetUserName,
      targetSkillId: targetSkillId ?? this.targetSkillId,
      targetSkillName: targetSkillName ?? this.targetSkillName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    id,
    requesterId,
    requesterName,
    requesterSkillId,
    requesterSkillName,
    targetUserId,
    targetUserName,
    targetSkillId,
    targetSkillName,
    status,
    createdAt,
    updatedAt,
    message,
  ];
}
