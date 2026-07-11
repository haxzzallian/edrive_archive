// lib/features/dashboard/domain/repositories/dashboard_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/dashboard_entity.dart';

abstract class DashboardRepository {
  /// GET /rides/statistics/my-rides + GET /auth/dashboard (parallel)
  Future<Either<Failure, DashboardEntity>> getDashboard();
}
