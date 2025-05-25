// Connection Request State
class ConnectionState {
  final List<ConnectionRequest> receivedRequests;
  final List<ConnectionRequest> sentRequests;
  final List<ConnectionRequest> acceptedConnections;
  final bool isLoading;
  final String? errorMessage;

  const ConnectionState({
    this.receivedRequests = const [],
    this.sentRequests = const [],
    this.acceptedConnections = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ConnectionState copyWith({
    List<ConnectionRequest>? receivedRequests,
    List<ConnectionRequest>? sentRequests,
    List<ConnectionRequest>? acceptedConnections,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ConnectionState(
      receivedRequests: receivedRequests ?? this.receivedRequests,
      sentRequests: sentRequests ?? this.sentRequests,
      acceptedConnections: acceptedConnections ?? this.acceptedConnections,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// Connection Request Model
class ConnectionRequest {
  final String id;
  final String skillId;
  final String skillName;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final String message;
  final ConnectionStatus status;
  final DateTime createdAt;

  ConnectionRequest({
    required this.id,
    required this.skillId,
    required this.skillName,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.message,
    required this.status,
    required this.createdAt,
  });
}

enum ConnectionStatus { pending, accepted, rejected }
