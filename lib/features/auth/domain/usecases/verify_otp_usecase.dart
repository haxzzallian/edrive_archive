// lib/features/auth/domain/usecases/verify_otp_usecase.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository _repo;
  VerifyOtpUseCase(this._repo);

  Future<Either<Failure, void>> call({
    required String email,
    required String code, // ← renamed from otp to code
  }) =>
      _repo.verifyEmail(email: email, code: code);
}
