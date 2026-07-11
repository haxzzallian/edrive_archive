// lib/features/auth/domain/usecases/forgot_password_usecase.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository _repo;
  ForgotPasswordUseCase(this._repo);

  Future<Either<Failure, void>> call({required String email}) =>
      _repo.forgotPassword(email: email);
}
