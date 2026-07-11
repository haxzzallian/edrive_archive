// lib/features/auth/domain/usecases/resend_otp_usecase.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class ResendOtpUseCase {
  final AuthRepository _repo;
  ResendOtpUseCase(this._repo);

  Future<Either<Failure, void>> call({required String email}) =>
      _repo.resendOtp(email: email);
}
