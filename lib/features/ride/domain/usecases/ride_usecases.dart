// lib/features/ride/domain/usecases/ride_usecases.dart
// All ride use cases in one file for brevity

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/ride_entity.dart';
import '../repositories/ride_repository.dart';

class CreateRideUseCase {
  final RideRepository _repo;
  CreateRideUseCase(this._repo);
  Future<Either<Failure, RideEntity>> call(CreateRideParams params) =>
      _repo.createRide(params);
}

class GetClientRidesUseCase {
  final RideRepository _repo;
  GetClientRidesUseCase(this._repo);
  Future<Either<Failure, List<RideEntity>>> call() => _repo.getClientRides();
}

class GetRideChatUseCase {
  final RideRepository _repo;
  GetRideChatUseCase(this._repo);
  Future<Either<Failure, List<DriverInteractionEntity>>> call(String rideId) =>
      _repo.getRideChat(rideId);
}

class CancelRideUseCase {
  final RideRepository _repo;
  CancelRideUseCase(this._repo);
  Future<Either<Failure, RideEntity>> call(String rideId) =>
      _repo.cancelRide(rideId);
}
