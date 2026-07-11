import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/driver_repository.dart';

class AcceptRideUseCase {
  final DriverRepository _repo;
  AcceptRideUseCase(this._repo);
  Future<Either<Failure, void>> call(String rideId) => _repo.acceptRide(rideId);
}
