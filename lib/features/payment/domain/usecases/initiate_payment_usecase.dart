import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/payment_repository.dart';

class InitiatePaymentUseCase {
  final PaymentRepository _repo;
  InitiatePaymentUseCase(this._repo);
  Future<Either<Failure, Map<String, dynamic>>> call({required String rideId, required String paymentMethodId}) =>
    _repo.initiatePayment(rideId: rideId, paymentMethodId: paymentMethodId);
}
