import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillsync/bloc/auth/auth_event.dart';
import 'package:skillsync/bloc/auth/auth_state.dart';
import 'package:skillsync/repositories/auth_repository.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthState()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
  }

  void _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = _authRepository.currentUser;
    if (user != null) {
      final userData = await _authRepository.getUserData(user.uid);
      emit(state.copyWith(status: AuthStatus.authenticated, user: userData));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  void _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final user = await _authRepository.signUpWithEmailAndPassword(
        email: event.email,
        password: event.password,
        name: event.name,
      );
      if (user != null) {
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            isLoading: false,
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
    }
  }

  void _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final user = await _authRepository.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      if (user != null) {
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            isLoading: false,
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
    }
  }

  void _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
    emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
  }
}
