import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/place_entity.dart';
import '../repositories/map_repository.dart';

class SearchPlacesUseCase {
  final MapRepository _repo;
  SearchPlacesUseCase(this._repo);
  Future<Either<Failure, List<PlaceEntity>>> call(String query) => _repo.searchPlaces(query);
}
