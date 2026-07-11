import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/fare_estimate_entity.dart';
import '../entities/place_entity.dart';
import '../entities/nearby_driver_entity.dart';

abstract class MapRepository {
  Future<Either<Failure, List<PlaceEntity>>> searchPlaces(String query);
  Future<Either<Failure, List<FareEstimateEntity>>> getFareEstimate({
    required double pickupLat, required double pickupLng,
    required double destLat, required double destLng,
  });
  Future<Either<Failure, List<NearbyDriverEntity>>> getNearbyDrivers({required double lat, required double lng});
}
