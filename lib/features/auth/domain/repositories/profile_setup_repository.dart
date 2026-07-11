// lib/features/profile_setup/domain/repositories/profile_setup_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/create_profile_params.dart';
import '../entities/profile_entity.dart';

abstract class ProfileSetupRepository {
  Future<Either<Failure, ProfileEntity>> createClientProfile(
      CreateClientProfileParams params);
  Future<Either<Failure, ProfileEntity>> createDriverProfile(
      CreateDriverProfileParams params);
  Future<Either<Failure, String>> uploadImage(UploadImageParams params);
}
