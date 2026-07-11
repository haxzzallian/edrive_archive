// import 'package:dartz/dartz.dart';
// import 'package:dio/dio.dart';
// import '../../../../core/error/failures.dart';
// import '../../../../core/error/dio_error_handler.dart';
// import '../../domain/entities/profile_entity.dart';
// import '../../domain/repositories/profile_repository.dart';
// import '../datasources/profile_remote_datasource.dart';

// class ProfileRepositoryImpl implements ProfileRepository {
//   final ProfileRemoteDataSource _ds;
//   ProfileRepositoryImpl(this._ds);

//   ProfileEntity _parse(Map<String, dynamic> d) => ProfileEntity(
//     id: d['id']?.toString() ?? '', name: d['name'] ?? '',
//     email: d['email'] ?? '', phone: d['phone'] ?? '', role: d['role'] ?? 'rider',
//     avatarUrl: d['avatar_url'], rating: (d['rating'] as num?)?.toDouble() ?? 5.0,
//     totalRides: d['total_rides'] as int? ?? 0, isVerified: d['is_verified'] == true,
//   );

//   @override Future<Either<Failure, ProfileEntity>> getProfile() async {
//     try { return Right(_parse(await _ds.getProfile())); }
//     on DioException catch (e) { return Left(handleDioException(e)); }
//     catch (e) { return Left(UnknownFailure(e.toString())); }
//   }

//   @override Future<Either<Failure, ProfileEntity>> updateProfile(Map<String, dynamic> data) async {
//     try { return Right(_parse(await _ds.updateProfile(data))); }
//     on DioException catch (e) { return Left(handleDioException(e)); }
//     catch (e) { return Left(UnknownFailure(e.toString())); }
//   }

//   @override Future<Either<Failure, String>> uploadAvatar(String filePath) async {
//     try { return Right(await _ds.uploadAvatar(filePath)); }
//     on DioException catch (e) { return Left(handleDioException(e)); }
//     catch (e) { return Left(UnknownFailure(e.toString())); }
//   }
// }
