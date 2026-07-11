import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), actions: [
        IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => context.push(AppRoutes.editProfile)),
      ]),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (p) => ListView(padding: const EdgeInsets.all(16), children: [
          // Avatar
          Center(child: Stack(children: [
            CircleAvatar(radius: 48, backgroundImage: p.avatarUrl != null ? NetworkImage(p.avatarUrl!) : null,
              child: p.avatarUrl == null ? const Icon(Icons.person, size: 48) : null),
            Positioned(bottom: 0, right: 0, child: CircleAvatar(
              radius: 16, backgroundColor: AppColors.secondary,
              child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
            )),
          ])),
          const SizedBox(height: 16),
          Center(child: Text(p.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))),
          Center(child: Text(p.phone, style: const TextStyle(color: AppColors.textSecondary))),
          const SizedBox(height: 24),
          // Stats
          Row(children: [
            _stat('${p.rating.toStringAsFixed(1)}', 'Rating'),
            _stat('${p.totalRides}', 'Trips'),
            _stat(p.isVerified ? 'Yes' : 'No', 'Verified'),
          ]),
          const SizedBox(height: 24),
          // Menu
          _menuItem(Icons.payment, 'Payment Methods', () => context.push(AppRoutes.paymentMethods)),
          _menuItem(Icons.notifications_outlined, 'Notifications', () {}),
          _menuItem(Icons.help_outline, 'Support', () {}),
          _menuItem(Icons.settings_outlined, 'Settings', () {}),
          _menuItem(Icons.logout, 'Logout', () {}, color: AppColors.error),
        ]),
      ),
    );
  }

  Widget _stat(String value, String label) => Expanded(child: Column(children: [
    Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
    Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
  ]));

  Widget _menuItem(IconData icon, String title, VoidCallback onTap, {Color? color}) =>
    ListTile(
      leading: Icon(icon, color: color ?? AppColors.textPrimary),
      title: Text(title, style: TextStyle(color: color ?? AppColors.textPrimary)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
    );
}
