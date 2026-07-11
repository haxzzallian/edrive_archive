// lib/features/dashboard/domain/usecases/get_dashboard_usecase.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/dashboard_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardUseCase {
  final DashboardRepository _repo;
  GetDashboardUseCase(this._repo);

  Future<Either<Failure, DashboardEntity>> call() => _repo.getDashboard();
}
