import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/earnings_entity.dart';
import '../repositories/driver_repository.dart';

class GetDriverEarningsUseCase {
  final DriverRepository _repo;
  GetDriverEarningsUseCase(this._repo);
  Future<Either<Failure, EarningsEntity>> call() => _repo.getEarnings();
}
