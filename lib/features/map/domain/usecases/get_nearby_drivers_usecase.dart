import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/nearby_driver_entity.dart';
import '../repositories/map_repository.dart';

class GetNearbyDriversUseCase {
  final MapRepository _repo;
  GetNearbyDriversUseCase(this._repo);
  Future<Either<Failure, List<NearbyDriverEntity>>> call({required double lat, required double lng}) =>
    _repo.getNearbyDrivers(lat: lat, lng: lng);
}
