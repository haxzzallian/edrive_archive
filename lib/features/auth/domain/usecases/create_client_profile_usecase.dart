// lib/features/profile_setup/domain/usecases/create_client_profile_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/create_profile_params.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_setup_repository.dart';

class CreateClientProfileUseCase {
  final ProfileSetupRepository _repo;
  CreateClientProfileUseCase(this._repo);

  Future<Either<Failure, ProfileEntity>> call(
          CreateClientProfileParams params) =>
      _repo.createClientProfile(params);
}
