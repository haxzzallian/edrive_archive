// lib/features/ride/data/repositories/ride_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/dio_error_handler.dart';
import '../../domain/entities/ride_entity.dart';
import '../../domain/repositories/ride_repository.dart';
import '../datasources/ride_remote_datasource.dart';

class RideRepositoryImpl implements RideRepository {
  final RideRemoteDataSource _ds;
  RideRepositoryImpl(this._ds);

  @override
  Future<Either<Failure, RideEntity>> createRide(
      CreateRideParams params) async {
    try {
      final model = await _ds.createRide(params);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(handleDioException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RideEntity>>> getClientRides() async {
    try {
      final models = await _ds.getClientRides();
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(handleDioException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DriverInteractionEntity>>> getRideChat(
      String rideId) async {
    try {
      final models = await _ds.getRideChat(rideId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(handleDioException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RideEntity>> cancelRide(String rideId) async {
    try {
      final model = await _ds.cancelRide(rideId);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(handleDioException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
