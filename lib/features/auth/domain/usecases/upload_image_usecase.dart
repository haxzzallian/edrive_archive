// lib/features/profile_setup/domain/usecases/upload_image_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/create_profile_params.dart';
import '../repositories/profile_setup_repository.dart';

class UploadImageUseCase {
  final ProfileSetupRepository _repo;
  UploadImageUseCase(this._repo);

  Future<Either<Failure, String>> call(UploadImageParams params) =>
      _repo.uploadImage(params);
}
