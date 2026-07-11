import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/payment_repository.dart';

class AddPaymentMethodUseCase {
  final PaymentRepository _repo;
  AddPaymentMethodUseCase(this._repo);
  Future<Either<Failure, void>> call(Map<String, dynamic> data) => _repo.addPaymentMethod(data);
}
