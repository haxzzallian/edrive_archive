import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment_method_entity.dart';

abstract class PaymentRepository {
  Future<Either<Failure, List<PaymentMethodEntity>>> getPaymentMethods();
  Future<Either<Failure, void>> addPaymentMethod(Map<String, dynamic> data);
  Future<Either<Failure, Map<String, dynamic>>> initiatePayment({required String rideId, required String paymentMethodId});
  Future<Either<Failure, bool>> verifyPayment(String reference);
}
