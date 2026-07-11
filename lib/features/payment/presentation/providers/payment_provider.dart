import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../../domain/usecases/get_payment_methods_usecase.dart';

final paymentMethodsProvider = FutureProvider<List<PaymentMethodEntity>>((ref) async {
  final result = await getIt<GetPaymentMethodsUseCase>()();
  return result.fold((f) => throw f.message, (list) => list);
});

final selectedPaymentMethodProvider = StateProvider<PaymentMethodEntity?>((ref) {
  final methods = ref.watch(paymentMethodsProvider);
  return methods.maybeWhen(
    data: (list) => list.where((m) => m.isDefault).firstOrNull ?? list.firstOrNull,
    orElse: () => null,
  );
});
