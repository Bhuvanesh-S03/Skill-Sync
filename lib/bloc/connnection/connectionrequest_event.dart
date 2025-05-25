// Connection Request Events
abstract class ConnectionEvent {}

class ConnectionSendRequest extends ConnectionEvent {
  final String skillId;
  final String receiverId;
  final String message;

  ConnectionSendRequest({
    required this.skillId,
    required this.receiverId,
    required this.message,
  });
}

class ConnectionAcceptRequest extends ConnectionEvent {
  final String requestId;

  ConnectionAcceptRequest(this.requestId);
}

class ConnectionRejectRequest extends ConnectionEvent {
  final String requestId;

  ConnectionRejectRequest(this.requestId);
}

class ConnectionLoadReceived extends ConnectionEvent {}

class ConnectionLoadSent extends ConnectionEvent {}

class ConnectionLoadAccepted extends ConnectionEvent {}
