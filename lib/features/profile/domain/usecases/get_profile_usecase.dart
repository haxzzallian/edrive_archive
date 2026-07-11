import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository _repo;
  GetProfileUseCase(this._repo);
  Future<Either<Failure, ProfileEntity>> call() => _repo.getProfile();
}
