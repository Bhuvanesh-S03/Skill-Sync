// lib/bloc/request/request_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillsync/bloc/request/request_auth';
import 'package:skillsync/repositories/request_repository.dart';

class RequestBloc extends Bloc<RequestEvent, RequestState> {
  final RequestRepository _requestRepository;
  StreamSubscription? _incomingRequestsSubscription;
  StreamSubscription? _outgoingRequestsSubscription;

  RequestBloc({required RequestRepository requestRepository})
    : _requestRepository = requestRepository,
      super(const RequestState()) {
    on<RequestLoadRequested>(_onRequestLoadRequested);
    on<RequestSendRequested>(_onRequestSendRequested);
    on<RequestAcceptRequested>(_onRequestAcceptRequested);
    on<RequestRejectRequested>(_onRequestRejectRequested);
    on<IncomingRequestsUpdated>(_onIncomingRequestsUpdated);
    on<OutgoingRequestsUpdated>(_onOutgoingRequestsUpdated);
  }

  void _onRequestLoadRequested(
    RequestLoadRequested event,
    Emitter<RequestState> emit,
  ) {
    emit(state.copyWith(status: RequestStatus.loading, clearError: true));

    _incomingRequestsSubscription?.cancel();
    _outgoingRequestsSubscription?.cancel();

    _incomingRequestsSubscription = _requestRepository
        .getIncomingRequests()
        .listen(
          (requests) => add(IncomingRequestsUpdated(requests)),
          onError:
              (error) => emit(
                state.copyWith(
                  status: RequestStatus.error,
                  errorMessage: error.toString(),
                ),
              ),
        );

    _outgoingRequestsSubscription = _requestRepository
        .getOutgoingRequests()
        .listen(
          (requests) => add(OutgoingRequestsUpdated(requests)),
          onError:
              (error) => emit(
                state.copyWith(
                  status: RequestStatus.error,
                  errorMessage: error.toString(),
                ),
              ),
        );
  }

  void _onIncomingRequestsUpdated(
    IncomingRequestsUpdated event,
    Emitter<RequestState> emit,
  ) {
    emit(
      state.copyWith(
        status: RequestStatus.loaded,
        incomingRequests: event.requests,
        clearError: true,
      ),
    );
  }

  void _onOutgoingRequestsUpdated(
    OutgoingRequestsUpdated event,
    Emitter<RequestState> emit,
  ) {
    emit(
      state.copyWith(
        status: RequestStatus.loaded,
        outgoingRequests: event.requests,
        clearError: true,
      ),
    );
  }

  void _onRequestSendRequested(
    RequestSendRequested event,
    Emitter<RequestState> emit,
  ) async {
    try {
      emit(state.copyWith(status: RequestStatus.loading, clearError: true));

      await _requestRepository.sendSkillSwapRequest(
        targetUserId: event.targetUserId,
        targetUserName: event.targetUserName,
        targetSkillId: event.targetSkillId,
        targetSkillName: event.targetSkillName,
        requesterSkillId: event.requesterSkillId,
        requesterSkillName: event.requesterSkillName,
        message: event.message,
      );

      emit(state.copyWith(status: RequestStatus.loaded, clearError: true));
    } catch (e) {
      emit(
        state.copyWith(status: RequestStatus.error, errorMessage: e.toString()),
      );
    }
  }

  void _onRequestAcceptRequested(
    RequestAcceptRequested event,
    Emitter<RequestState> emit,
  ) async {
    try {
      emit(state.copyWith(status: RequestStatus.loading, clearError: true));
      await _requestRepository.acceptRequest(event.requestId);
      emit(state.copyWith(status: RequestStatus.loaded, clearError: true));
    } catch (e) {
      emit(
        state.copyWith(status: RequestStatus.error, errorMessage: e.toString()),
      );
    }
  }

  void _onRequestRejectRequested(
    RequestRejectRequested event,
    Emitter<RequestState> emit,
  ) async {
    try {
      emit(state.copyWith(status: RequestStatus.loading, clearError: true));
      await _requestRepository.rejectRequest(event.requestId);
      emit(state.copyWith(status: RequestStatus.loaded, clearError: true));
    } catch (e) {
      emit(
        state.copyWith(status: RequestStatus.error, errorMessage: e.toString()),
      );
    }
  }

  @override
  Future<void> close() {
    _incomingRequestsSubscription?.cancel();
    _outgoingRequestsSubscription?.cancel();
    return super.close();
  }
}
