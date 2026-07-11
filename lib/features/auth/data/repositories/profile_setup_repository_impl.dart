// lib/features/auth/data/repositories/profile_setup_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/dio_error_handler.dart';
import '../../domain/entities/create_profile_params.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_setup_repository.dart';
import '../datasources/profile_setup_remote_datasource.dart';
import '../models/profile_model.dart';

class ProfileSetupRepositoryImpl implements ProfileSetupRepository {
  final ProfileSetupRemoteDataSource _ds;
  ProfileSetupRepositoryImpl(this._ds);

  @override
  Future<Either<Failure, ProfileEntity>> createClientProfile(
      CreateClientProfileParams params) async {
    try {
      final body = _buildClientBody(params);
      final model = await _ds.createClientProfile(body);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(handleDioException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> createDriverProfile(
      CreateDriverProfileParams params) async {
    try {
      final body = _buildDriverBody(params);
      final model = await _ds.createDriverProfile(body);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(handleDioException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadImage(UploadImageParams params) async {
    try {
      final url = await _ds.uploadImage(
        filePath: params.filePath,
        folder: params.folder,
      );
      return Right(url);
    } on DioException catch (e) {
      return Left(handleDioException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ── Body builders ─────────────────────────────────────────────────────────

  Map<String, dynamic> _buildClientBody(CreateClientProfileParams p) {
    final loc = LocationModel(
      state: p.location.state,
      lga: p.location.lga,
      address: p.location.address,
      lat: p.location.lat,
      lng: p.location.lng,
    );
    return {
      'userEmail': p.userEmail,
      'isDriver': false,
      'question': p.question,
      'gender': p.gender,
      'role': 'client',
      'location': loc.toApiString(),
      'phoneNumber': p.phoneNumber,
      if (p.profilePictureUrl != null) 'profilePicture': p.profilePictureUrl,
    };
  }

  Map<String, dynamic> _buildDriverBody(CreateDriverProfileParams p) {
    final loc = LocationModel(
      state: p.location.state,
      lga: p.location.lga,
      address: p.location.address,
      lat: p.location.lat,
      lng: p.location.lng,
    );
    final car = CarDetailsModel(
      model: p.carDetails.model,
      product: p.carDetails.product,
      year: p.carDetails.year,
      color: p.carDetails.color,
      plateNumber: p.carDetails.plateNumber,
    );
    return {
      'userEmail': p.userEmail,
      'isDriver': true,
      'question': '',
      'gender': p.gender,
      'role': 'driver',
      'location': loc.toApiString(),
      'phoneNumber': p.phoneNumber,
      'carDetails': car.toApiString(),
      'maritalStatus': p.maritalStatus,
      'YOE': p.yoe,
      'rideOption': '',
      'currentLocation': p.currentLocation,
      'languageSpoken': p.languageSpoken,
      'gearType': p.gearType,
      'vehicleType': p.vehicleType,
      'driverRoles': p.driverRoles,
      'interstate': p.interstate,
      'certificateTraining': null,
      // Only include availableToBeHiredDetails when hired role is selected
      if (p.hiredDetails != null)
        'availableToBeHiredDetails': p.hiredDetails!.toJson(),
      if (p.profilePictureUrl != null) 'profilePicture': p.profilePictureUrl,
      if (p.carPictureUrl != null) 'carPicture': p.carPictureUrl,
      if (p.driverLicenseUrl != null) 'driverLicense': p.driverLicenseUrl,
    };
  }
}
