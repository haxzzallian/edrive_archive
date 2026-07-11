import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/driver_provider.dart';

class DriverDashboardPage extends ConsumerWidget {
  const DriverDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(driverOnlineProvider);
    final earnings = ref.watch(earningsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: online.isOnline ? AppColors.secondary : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            Expanded(child: Text(online.isOnline ? 'You are Online' : 'You are Offline',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: online.isOnline ? Colors.white : AppColors.textPrimary))),
            Switch(value: online.isOnline, onChanged: (_) => ref.read(driverOnlineProvider.notifier).toggleOnline(), activeColor: Colors.white),
          ]),
        ),
        const SizedBox(height: 20),
        earnings.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
          data: (e) => Row(children: [
            _card('Today', '₦${e.today.toStringAsFixed(0)}'),
            const SizedBox(width: 12),
            _card('Week', '₦${e.thisWeek.toStringAsFixed(0)}'),
            const SizedBox(width: 12),
            _card('Month', '₦${e.thisMonth.toStringAsFixed(0)}'),
          ]),
        ),
      ]),
    );
  }

  Widget _card(String label, String value) => Expanded(child: Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
    child: Column(children: [
      Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
    ]),
  ));
}
