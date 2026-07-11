// lib/features/ride/domain/repositories/ride_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/ride_entity.dart';

abstract class RideRepository {
  /// POST /rides — creates ride, returns ride + fare
  Future<Either<Failure, RideEntity>> createRide(CreateRideParams params);

  /// GET /rides/client — all client rides (used for polling)
  Future<Either<Failure, List<RideEntity>>> getClientRides();

  /// GET /rides/:id/chat — driver offers for a specific ride
  Future<Either<Failure, List<DriverInteractionEntity>>> getRideChat(
      String rideId);

  /// POST /rides/:id/cancel
  Future<Either<Failure, RideEntity>> cancelRide(String rideId);
}
