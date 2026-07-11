import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/driver_entity.dart';
import '../entities/earnings_entity.dart';

abstract class DriverRepository {
  Future<Either<Failure, void>> goOnline({required double lat, required double lng});
  Future<Either<Failure, void>> goOffline();
  Future<Either<Failure, void>> acceptRide(String rideId);
  Future<Either<Failure, void>> declineRide(String rideId);
  Future<Either<Failure, EarningsEntity>> getEarnings();
  Future<Either<Failure, DriverEntity>> getDriverProfile();
}
