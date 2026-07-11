// lib/features/auth/presentation/providers/auth_state.dart

import '../../domain/entities/auth_entity.dart';
import '../../domain/entities/user_entity.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? error;
  final AuthEntity? session; // set after login
  final UserEntity? registered; // set after register (before verification)

  const AuthState({
    this.status = AuthStatus.initial,
    this.error,
    this.session,
    this.registered,
  });

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    String? error,
    AuthEntity? session,
    UserEntity? registered,
    bool clearError = false,
  }) =>
      AuthState(
        status: status ?? this.status,
        error: clearError ? null : (error ?? this.error),
        session: session ?? this.session,
        registered: registered ?? this.registered,
      );
}
