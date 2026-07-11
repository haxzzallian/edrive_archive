import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentMethodsPage extends ConsumerWidget {
  const PaymentMethodsPage({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) =>
    Scaffold(appBar: AppBar(title: const Text('Payment Methods')), body: const Center(child: Text('Payment Methods — TODO')));
}
