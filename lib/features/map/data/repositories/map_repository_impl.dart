// import 'package:dartz/dartz.dart';
// import 'package:dio/dio.dart';
// import '../../../../core/error/failures.dart';
// import '../../../../core/error/dio_error_handler.dart';
// import '../../domain/entities/fare_estimate_entity.dart';
// import '../../domain/entities/place_entity.dart';
// import '../../domain/entities/nearby_driver_entity.dart';
// import '../../domain/repositories/map_repository.dart';
// import '../datasources/map_remote_datasource.dart';

// class MapRepositoryImpl implements MapRepository {
//   final MapRemoteDataSource _ds;
//   MapRepositoryImpl(this._ds);

//   @override Future<Either<Failure, List<PlaceEntity>>> searchPlaces(String query) async {
//     try {
//       final raw = await _ds.searchPlaces(query);
//       return Right(raw.map((e) {
//         final m = e as Map<String, dynamic>;
//         return PlaceEntity(
//           placeId: m['place_id'] ?? '', name: m['name'] ?? '',
//           address: m['address'] ?? '', lat: (m['lat'] as num).toDouble(), lng: (m['lng'] as num).toDouble(),
//         );
//       }).toList());
//     } on DioException catch (e) { return Left(handleDioException(e)); }
//     catch (e) { return Left(UnknownFailure(e.toString())); }
//   }

//   @override Future<Either<Failure, List<FareEstimateEntity>>> getFareEstimate({
//     required double pickupLat, required double pickupLng,
//     required double destLat, required double destLng,
//   }) async {
//     try {
//       final raw = await _ds.getFareEstimate({
//         'pickup_lat': pickupLat, 'pickup_lng': pickupLng, 'dest_lat': destLat, 'dest_lng': destLng,
//       });
//       return Right(raw.map((e) {
//         final m = e as Map<String, dynamic>;
//         return FareEstimateEntity(
//           vehicleTypeId: m['vehicle_type_id'] ?? '',
//           fare: (m['fare'] as num).toDouble(),
//           distanceKm: (m['distance_km'] as num).toDouble(),
//           durationSeconds: m['duration_seconds'] as int? ?? 0,
//         );
//       }).toList());
//     } on DioException catch (e) { return Left(handleDioException(e)); }
//     catch (e) { return Left(UnknownFailure(e.toString())); }
//   }

//   @override Future<Either<Failure, List<NearbyDriverEntity>>> getNearbyDrivers({required double lat, required double lng}) async {
//     try {
//       final raw = await _ds.getNearbyDrivers(lat: lat, lng: lng);
//       return Right(raw.map((e) {
//         final m = e as Map<String, dynamic>;
//         return NearbyDriverEntity(
//           driverId: m['driver_id'] ?? '', lat: (m['lat'] as num).toDouble(),
//           lng: (m['lng'] as num).toDouble(), heading: (m['heading'] as num?)?.toDouble() ?? 0,
//           vehicleType: m['vehicle_type'] ?? 'standard',
//         );
//       }).toList());
//     } on DioException catch (e) { return Left(handleDioException(e)); }
//     catch (e) { return Left(UnknownFailure(e.toString())); }
//   }
// }
