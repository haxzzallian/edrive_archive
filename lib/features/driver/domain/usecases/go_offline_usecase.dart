import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/driver_repository.dart';

class GoOfflineUseCase {
  final DriverRepository _repo;
  GoOfflineUseCase(this._repo);
  Future<Either<Failure, void>> call() => _repo.goOffline();
}
