import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/driver_repository.dart';

class GoOnlineUseCase {
  final DriverRepository _repo;
  GoOnlineUseCase(this._repo);
  Future<Either<Failure, void>> call({required double lat, required double lng}) =>
    _repo.goOnline(lat: lat, lng: lng);
}
