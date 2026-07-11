// lib/features/dashboard/data/repositories/dashboard_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/dio_error_handler.dart';
import '../../domain/entities/dashboard_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../models/dashboard_model.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _ds;
  DashboardRepositoryImpl(this._ds);

  @override
  Future<Either<Failure, DashboardEntity>> getDashboard() async {
    try {
      // Fire both requests in parallel
      final results = await Future.wait([
        _ds.getStats(),
        _ds.getProfile(),
      ]);
      final stats = RideStatsModel.fromJson(results[0]);
      final profile = DashboardProfileModel.fromJson(results[1]);
      return Right(DashboardEntity(
        stats: stats.toEntity(),
        profile: profile.toEntity(),
      ));
    } on DioException catch (e) {
      return Left(handleDioException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
