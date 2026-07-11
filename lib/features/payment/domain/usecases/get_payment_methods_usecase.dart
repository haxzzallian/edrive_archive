import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment_method_entity.dart';
import '../repositories/payment_repository.dart';

class GetPaymentMethodsUseCase {
  final PaymentRepository _repo;
  GetPaymentMethodsUseCase(this._repo);
  Future<Either<Failure, List<PaymentMethodEntity>>> call() => _repo.getPaymentMethods();
}
