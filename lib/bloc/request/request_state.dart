// lib/bloc/request/request_state.dart
import 'package:equatable/equatable.dart';
import 'package:skillsync/models/request_model.dart';

enum RequestStatus { initial, loading, loaded, error }

class RequestState extends Equatable {
  final RequestStatus status;
  final List<SkillSwapRequest> incomingRequests;
  final List<SkillSwapRequest> outgoingRequests;
  final String? errorMessage;

  const RequestState({
    this.status = RequestStatus.initial,
    this.incomingRequests = const [],
    this.outgoingRequests = const [],
    this.errorMessage,
  });

  RequestState copyWith({
    RequestStatus? status,
    List<SkillSwapRequest>? incomingRequests,
    List<SkillSwapRequest>? outgoingRequests,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RequestState(
      status: status ?? this.status,
      incomingRequests: incomingRequests ?? this.incomingRequests,
      outgoingRequests: outgoingRequests ?? this.outgoingRequests,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    incomingRequests,
    outgoingRequests,
    errorMessage,
  ];
}
