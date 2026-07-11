// lib/features/profile_setup/domain/usecases/create_driver_profile_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/create_profile_params.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_setup_repository.dart';

class CreateDriverProfileUseCase {
  final ProfileSetupRepository _repo;
  CreateDriverProfileUseCase(this._repo);

  Future<Either<Failure, ProfileEntity>> call(
          CreateDriverProfileParams params) =>
      _repo.createDriverProfile(params);
}
