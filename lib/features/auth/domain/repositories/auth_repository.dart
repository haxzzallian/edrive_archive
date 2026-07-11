// lib/features/auth/domain/repositories/auth_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_entity.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
  });

  /// POST /auth/verify-email — body: { email, code }
  Future<Either<Failure, void>> verifyEmail({
    required String email,
    required String code, // ← renamed from otp to code
  });

  Future<Either<Failure, void>> resendOtp({required String email});

  Future<Either<Failure, void>> forgotPassword({required String email});
}
