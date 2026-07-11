// import 'package:dartz/dartz.dart';
// import 'package:dio/dio.dart';
// import '../../../../core/error/failures.dart';
// import '../../../../core/error/dio_error_handler.dart';
// import '../../domain/entities/payment_method_entity.dart';
// import '../../domain/repositories/payment_repository.dart';
// import '../datasources/payment_remote_datasource.dart';

// class PaymentRepositoryImpl implements PaymentRepository {
//   final PaymentRemoteDataSource _ds;
//   PaymentRepositoryImpl(this._ds);

//   @override Future<Either<Failure, List<PaymentMethodEntity>>> getPaymentMethods() async {
//     try {
//       final raw = await _ds.getPaymentMethods();
//       return Right(raw.map((e) {
//         final m = e as Map<String, dynamic>;
//         return PaymentMethodEntity(
//           id: m['id']?.toString() ?? '',
//           type: _parseType(m['type']),
//           label: m['label'] ?? '',
//           isDefault: m['is_default'] == true,
//         );
//       }).toList());
//     } on DioException catch (e) { return Left(handleDioException(e)); }
//     catch (e) { return Left(UnknownFailure(e.toString())); }
//   }

//   @override Future<Either<Failure, void>> addPaymentMethod(Map<String, dynamic> data) async {
//     try { await _ds.addPaymentMethod(data); return const Right(null); }
//     on DioException catch (e) { return Left(handleDioException(e)); }
//     catch (e) { return Left(UnknownFailure(e.toString())); }
//   }

//   @override Future<Either<Failure, Map<String, dynamic>>> initiatePayment({required String rideId, required String paymentMethodId}) async {
//     try { return Right(await _ds.initiatePayment({'ride_id': rideId, 'payment_method_id': paymentMethodId})); }
//     on DioException catch (e) { return Left(handleDioException(e)); }
//     catch (e) { return Left(UnknownFailure(e.toString())); }
//   }

//   @override Future<Either<Failure, bool>> verifyPayment(String reference) async {
//     try {
//       final data = await _ds.verifyPayment(reference);
//       return Right(data['success'] == true);
//     } on DioException catch (e) { return Left(handleDioException(e)); }
//     catch (e) { return Left(UnknownFailure(e.toString())); }
//   }

//   PaymentType _parseType(dynamic t) => switch(t) {
//     'card' => PaymentType.card,
//     'bank_transfer' => PaymentType.bankTransfer,
//     'wallet' => PaymentType.wallet,
//     _ => PaymentType.cash,
//   };
// }
