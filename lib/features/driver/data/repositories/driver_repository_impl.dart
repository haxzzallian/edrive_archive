// import 'package:dartz/dartz.dart';
// import 'package:dio/dio.dart';
// import '../../../../core/error/failures.dart';
// import '../../../../core/error/dio_error_handler.dart';
// import '../../domain/entities/driver_entity.dart';
// import '../../domain/entities/earnings_entity.dart';
// import '../../domain/repositories/driver_repository.dart';
// import '../datasources/driver_remote_datasource.dart';

// class DriverRepositoryImpl implements DriverRepository {
//   final DriverRemoteDataSource _ds;
//   DriverRepositoryImpl(this._ds);

//   @override Future<Either<Failure, void>> goOnline({required double lat, required double lng}) async {
//     try { await _ds.goOnline(lat: lat, lng: lng); return const Right(null); }
//     on DioException catch (e) { return Left(handleDioException(e)); }
//     catch (e) { return Left(UnknownFailure(e.toString())); }
//   }
//   @override Future<Either<Failure, void>> goOffline() async {
//     try { await _ds.goOffline(); return const Right(null); }
//     on DioException catch (e) { return Left(handleDioException(e)); }
//     catch (e) { return Left(UnknownFailure(e.toString())); }
//   }
//   @override Future<Either<Failure, void>> acceptRide(String rideId) async {
//     try { await _ds.acceptRide(rideId); return const Right(null); }
//     on DioException catch (e) { return Left(handleDioException(e)); }
//     catch (e) { return Left(UnknownFailure(e.toString())); }
//   }
//   @override Future<Either<Failure, void>> declineRide(String rideId) async {
//     try { await _ds.declineRide(rideId); return const Right(null); }
//     on DioException catch (e) { return Left(handleDioException(e)); }
//     catch (e) { return Left(UnknownFailure(e.toString())); }
//   }
//   @override Future<Either<Failure, EarningsEntity>> getEarnings() async {
//     try {
//       final data = await _ds.getEarnings();
//       return Right(EarningsEntity(
//         today: (data['today'] as num?)?.toDouble() ?? 0,
//         thisWeek: (data['this_week'] as num?)?.toDouble() ?? 0,
//         thisMonth: (data['this_month'] as num?)?.toDouble() ?? 0,
//         total: (data['total'] as num?)?.toDouble() ?? 0,
//         entries: [],
//       ));
//     } on DioException catch (e) { return Left(handleDioException(e)); }
//     catch (e) { return Left(UnknownFailure(e.toString())); }
//   }
//   @override Future<Either<Failure, DriverEntity>> getDriverProfile() async {
//     try {
//       final data = await _ds.getDriverProfile();
//       return Right(DriverEntity(
//         id: data['id']?.toString() ?? '',
//         name: data['name'] ?? '',
//         phone: data['phone'] ?? '',
//         rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
//         isOnline: data['is_online'] == true,
//         totalEarnings: (data['total_earnings'] as num?)?.toDouble() ?? 0,
//         totalRides: data['total_rides'] as int? ?? 0,
//       ));
//     } on DioException catch (e) { return Left(handleDioException(e)); }
//     catch (e) { return Left(UnknownFailure(e.toString())); }
//   }
// }
