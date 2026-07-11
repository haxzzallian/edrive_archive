import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TripDetailPage extends ConsumerWidget {
  final String rideId;
  const TripDetailPage({super.key, required this.rideId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trip Details')),
      body: Center(child: Text('Trip $rideId — TODO')),
    );
  }
}
