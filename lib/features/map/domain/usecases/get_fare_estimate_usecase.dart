import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/fare_estimate_entity.dart';
import '../repositories/map_repository.dart';

class GetFareEstimateUseCase {
  final MapRepository _repo;
  GetFareEstimateUseCase(this._repo);
  Future<Either<Failure, List<FareEstimateEntity>>> call({
    required double pickupLat, required double pickupLng,
    required double destLat, required double destLng,
  }) => _repo.getFareEstimate(pickupLat: pickupLat, pickupLng: pickupLng, destLat: destLat, destLng: destLng);
}
