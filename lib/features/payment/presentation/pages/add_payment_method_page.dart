import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddPaymentMethodPage extends ConsumerWidget {
  const AddPaymentMethodPage({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) =>
    Scaffold(appBar: AppBar(title: const Text('Add Payment Method')), body: const Center(child: Text('Add Payment — TODO')));
}
