// lib/features/auth/presentation/providers/auth_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/token_storage.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/usecases/resend_otp_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _login;
  final RegisterUseCase _register;
  final VerifyOtpUseCase _verifyOtp;
  final ResendOtpUseCase _resendOtp;
  final ForgotPasswordUseCase _forgotPassword;

  AuthNotifier(
    this._login,
    this._register,
    this._verifyOtp,
    this._resendOtp,
    this._forgotPassword,
  ) : super(AuthState(
          status: TokenStorage.instance.hasToken
              ? AuthStatus.authenticated
              : AuthStatus.unauthenticated,
        ));

  void clearError() => state = state.copyWith(clearError: true);

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    final result = await _login(email: email, password: password);
    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: failure.message,
        );
        return false;
      },
      (session) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          session: session,
        );
        return true;
      },
    );
  }

  Future<String?> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    final result = await _register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      role: role,
    );
    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: failure.message,
        );
        return null;
      },
      (user) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          registered: user,
        );
        return email;
      },
    );
  }

  // ── verifyOtp now passes code instead of otp ──────────────────────────────
  Future<bool> verifyOtp({
    required String email,
    required String code, // ← renamed from otp to code
  }) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    final result = await _verifyOtp(email: email, code: code);
    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return true;
      },
    );
  }

  Future<bool> resendOtp({required String email}) async {
    final result = await _resendOtp(email: email);
    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (_) => true,
    );
  }

  Future<bool> forgotPassword({required String email}) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    final result = await _forgotPassword(email: email);
    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return true;
      },
    );
  }

  Future<void> logout() async {
    await TokenStorage.instance.clearSession();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(
    getIt<LoginUseCase>(),
    getIt<RegisterUseCase>(),
    getIt<VerifyOtpUseCase>(),
    getIt<ResendOtpUseCase>(),
    getIt<ForgotPasswordUseCase>(),
  ),
);
