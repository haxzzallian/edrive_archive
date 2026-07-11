// lib/features/auth/domain/usecases/login_usecase.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repo;
  LoginUseCase(this._repo);

  Future<Either<Failure, AuthEntity>> call({
    required String email,
    required String password,
  }) =>
      _repo.login(email: email, password: password);
}
