// lib/features/auth/data/repositories/auth_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/dio_error_handler.dart';
import '../../../../core/services/token_storage.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _ds;
  AuthRepositoryImpl(this._ds);

  @override
  Future<Either<Failure, AuthEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final model = await _ds.login(email: email, password: password);
      final entity = model.toEntity();
      await TokenStorage.instance.saveSession(
        token: entity.token,
        userId: entity.userId,
        role: entity.role,
        email: entity.email,
      );
      return Right(entity);
    } on DioException catch (e) {
      return Left(handleDioException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final model = await _ds.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        role: role,
      );
      await TokenStorage.instance.savePendingVerification(
        email: email,
        role: role,
      );
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(handleDioException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      await _ds.verifyEmail(email: email, code: code);
      // ── DO NOT clear pendingRole here ────────────────────────────────────
      // The page reads pendingRole AFTER this returns to decide where to
      // navigate. Clearing it here wipes it before the page can read it.
      // clearPendingVerification() is called by the page after navigation.
      return const Right(null);
    } on DioException catch (e) {
      return Left(handleDioException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resendOtp({required String email}) async {
    try {
      await _ds.resendOtp(email: email);
      return const Right(null);
    } on DioException catch (e) {
      return Left(handleDioException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) async {
    try {
      await _ds.forgotPassword(email: email);
      return const Right(null);
    } on DioException catch (e) {
      return Left(handleDioException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}

// // lib/features/auth/data/repositories/auth_repository_impl.dart

// import 'package:dartz/dartz.dart';
// import 'package:dio/dio.dart';
// import '../../../../core/error/failures.dart';
// import '../../../../core/error/dio_error_handler.dart';
// import '../../../../core/services/token_storage.dart';
// import '../../domain/entities/auth_entity.dart';
// import '../../domain/entities/user_entity.dart';
// import '../../domain/repositories/auth_repository.dart';
// import '../datasources/auth_remote_datasource.dart';

// class AuthRepositoryImpl implements AuthRepository {
//   final AuthRemoteDataSource _ds;
//   AuthRepositoryImpl(this._ds);

//   @override
//   Future<Either<Failure, AuthEntity>> login({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final model = await _ds.login(email: email, password: password);
//       final entity = model.toEntity();
//       await TokenStorage.instance.saveSession(
//         token: entity.token,
//         userId: entity.userId,
//         role: entity.role,
//         email: entity.email,
//       );
//       return Right(entity);
//     } on DioException catch (e) {
//       return Left(handleDioException(e));
//     } catch (e) {
//       return Left(UnknownFailure(e.toString()));
//     }
//   }

//   @override
//   Future<Either<Failure, UserEntity>> register({
//     required String firstName,
//     required String lastName,
//     required String email,
//     required String password,
//     required String role,
//   }) async {
//     try {
//       final model = await _ds.register(
//         firstName: firstName,
//         lastName: lastName,
//         email: email,
//         password: password,
//         role: role,
//       );
//       await TokenStorage.instance.savePendingVerification(
//         email: email,
//         role: role,
//       );
//       return Right(model.toEntity());
//     } on DioException catch (e) {
//       return Left(handleDioException(e));
//     } catch (e) {
//       return Left(UnknownFailure(e.toString()));
//     }
//   }

//   @override
//   Future<Either<Failure, void>> verifyEmail({
//     required String email,
//     required String code, // ← renamed from otp to code
//   }) async {
//     try {
//       await _ds.verifyEmail(email: email, code: code);
//       await TokenStorage.instance.clearPendingVerification();
//       return const Right(null);
//     } on DioException catch (e) {
//       return Left(handleDioException(e));
//     } catch (e) {
//       return Left(UnknownFailure(e.toString()));
//     }
//   }

//   @override
//   Future<Either<Failure, void>> resendOtp({required String email}) async {
//     try {
//       await _ds.resendOtp(email: email);
//       return const Right(null);
//     } on DioException catch (e) {
//       return Left(handleDioException(e));
//     } catch (e) {
//       return Left(UnknownFailure(e.toString()));
//     }
//   }

//   @override
//   Future<Either<Failure, void>> forgotPassword({required String email}) async {
//     try {
//       await _ds.forgotPassword(email: email);
//       return const Right(null);
//     } on DioException catch (e) {
//       return Left(handleDioException(e));
//     } catch (e) {
//       return Left(UnknownFailure(e.toString()));
//     }
//   }
// }
