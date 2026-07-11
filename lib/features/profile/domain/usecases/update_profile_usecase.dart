import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository _repo;
  UpdateProfileUseCase(this._repo);
  Future<Either<Failure, ProfileEntity>> call(Map<String, dynamic> data) => _repo.updateProfile(data);
}
