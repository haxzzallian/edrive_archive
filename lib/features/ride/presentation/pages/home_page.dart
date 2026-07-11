// lib/features/ride/presentation/pages/home_page.dart
//
// Client home page. Calls on load:
//   GET /rides/statistics/my-rides  — ride stats
//   GET /auth/dashboard             — profile
//   GET /rides/client               — active + recent rides
//
// Layout:
//   Full-screen Google Map (current GPS location)
//   Top bar: menu + profile avatar
//   Recenter FAB
//   Bottom draggable sheet:
//     - Greeting + profile name
//     - Stats row (total rides, completion rate, amount spent)
//     - "Where to?" search bar → BookRidePage
//     - Active ride card (if pending ride exists)
//     - Recent rides list

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/token_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../dashboard/presentation/providers/dashboard_notifier.dart';
import '../../../dashboard/presentation/providers/dashboard_state.dart';
import '../../../dashboard/domain/entities/dashboard_entity.dart';
import '../providers/ride_notifier.dart';
import '../providers/ride_state.dart';

// ── Page ──────────────────────────────────────────────────────────────────────
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapController? _mapController;
  LatLng _currentLatLng = const LatLng(6.5244, 3.3792);
  bool _locationLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadLocation();
    // Load client rides for active ride detection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rideProvider.notifier).loadHistory();
    });
  }

  Future<void> _loadLocation() async {
    try {
      final pos = await LocationService.instance.getCurrentPosition();
      final latLng = LatLng(pos.latitude, pos.longitude);
      if (!mounted) return;
      setState(() {
        _currentLatLng = latLng;
        _locationLoaded = true;
      });
      _mapController?.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: 15)));
    } catch (_) {
      // Silent — map stays at Lagos default
    }
  }

  void _onMapCreated(GoogleMapController c) {
    _mapController = c;
    if (_locationLoaded) {
      c.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentLatLng, zoom: 15)));
    }
  }

  void _recenter() =>
      _mapController?.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentLatLng, zoom: 15)));

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dashboard = ref.watch(dashboardProvider);
    final rideState = ref.watch(rideProvider);

    // Resume polling if there's a pending active ride
    ref.listen(rideProvider.select((s) => s.activeRide), (_, ride) {
      if (ride != null && ride.isPending) {
        ref.read(rideProvider.notifier).resumeIfActive();
      }
    });

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: Stack(children: [
        // ── Google Map ────────────────────────────────────────────────────
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition:
              CameraPosition(target: _currentLatLng, zoom: 14),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          markers: {
            Marker(
                markerId: const MarkerId('current'),
                position: _currentLatLng,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen)),
          },
        ),

        // ── Top bar ───────────────────────────────────────────────────────
        SafeArea(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            // Menu button — opens drawer
            _CircleBtn(
              icon: Icons.menu_rounded,
              isDark: isDark,
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            const Spacer(),
            // Profile avatar
            GestureDetector(
              onTap: () => context.push(AppRoutes.profile),
              child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ]),
                  child: dashboard.profilePicture != null
                      ? ClipOval(
                          child: Image.network(dashboard.profilePicture!,
                              fit: BoxFit.cover))
                      : Center(
                          child: Text(
                              dashboard.firstName.isNotEmpty
                                  ? dashboard.firstName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800)))),
            ),
          ]),
        )),

        // ── Recenter button ───────────────────────────────────────────────
        Positioned(
            right: 16,
            bottom: 290,
            child: _CircleBtn(
              icon: Icons.my_location_rounded,
              isDark: isDark,
              iconColor: AppColors.secondary,
              onTap: _recenter,
            )),

        // ── Bottom draggable sheet ────────────────────────────────────────
        DraggableScrollableSheet(
          initialChildSize: 0.38,
          minChildSize: 0.18,
          maxChildSize: 0.75,
          builder: (_, ctrl) => Container(
            decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 20,
                      offset: const Offset(0, -4))
                ]),
            child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                // Drag handle
                Center(
                    child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkDivider
                                : AppColors.divider,
                            borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),

                // ── Greeting ─────────────────────────────────────────────
                if (dashboard.isLoading)
                  const SizedBox(
                      height: 20,
                      child: LinearProgressIndicator(
                          color: AppColors.secondary,
                          backgroundColor: Colors.transparent))
                else ...[
                  Text(
                      _greeting() +
                          (dashboard.firstName.isNotEmpty
                              ? ', ${dashboard.firstName}!'
                              : '!'),
                      style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                          fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('Where to?',
                      style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w900)),
                ],
                const SizedBox(height: 14),

                // ── Stats row ─────────────────────────────────────────────
                if (!dashboard.isLoading)
                  _StatsRow(stats: dashboard, isDark: isDark),
                const SizedBox(height: 16),

                // ── Search bar ────────────────────────────────────────────
                GestureDetector(
                    onTap: () =>
                        context.push(AppRoutes.bookRide, extra: _currentLatLng),
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 15),
                        decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurfaceVariant
                                : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(14)),
                        child: Row(children: [
                          Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                  color: AppColors.secondary,
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 10),
                          Text('Search destination',
                              style: TextStyle(
                                  color: AppColors.textHint, fontSize: 15)),
                          const Spacer(),
                          const Icon(Icons.search_rounded,
                              color: AppColors.textHint, size: 20),
                        ]))),
                const SizedBox(height: 16),

                // ── Active ride card ──────────────────────────────────────
                if (rideState.hasActiveRide && rideState.activeRide != null)
                  _ActiveRideCard(
                      ride: rideState.activeRide!,
                      isDark: isDark,
                      onTap: () => context.push(AppRoutes.bookRide,
                          extra: _currentLatLng)),
                if (rideState.hasActiveRide) const SizedBox(height: 16),

                // ── Recent rides ──────────────────────────────────────────
                if (rideState.rideHistory.isNotEmpty) ...[
                  Text('Recent Rides',
                      style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  ...rideState.rideHistory.take(3).map((ride) =>
                      _RecentRideCard(
                          ride: ride,
                          isDark: isDark,
                          onTap: () => context.push(AppRoutes.bookRide,
                              extra: _currentLatLng))),
                ],
              ],
            ),
          ),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final Color? iconColor;
  final VoidCallback onTap;
  const _CircleBtn(
      {required this.icon,
      required this.isDark,
      this.iconColor,
      required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ]),
          child: Icon(icon,
              color: iconColor ??
                  (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
              size: 22)));
}

class _StatsRow extends StatelessWidget {
  // Takes DashboardState directly — uses convenience getters, no null issues
  final DashboardState stats;
  final bool isDark;
  const _StatsRow({required this.stats, required this.isDark});
  @override
  Widget build(BuildContext context) => Row(children: [
        _StatChip(
            label: 'Total Rides',
            value: '${stats.totalRides}',
            color: AppColors.secondary,
            isDark: isDark),
        const SizedBox(width: 8),
        _StatChip(
            label: 'Completed',
            value: '${stats.completed}',
            color: AppColors.success,
            isDark: isDark),
        const SizedBox(width: 8),
        _StatChip(
            label: 'Spent',
            value: '₦${stats.totalSpent.toStringAsFixed(0)}',
            color: AppColors.info,
            isDark: isDark),
      ]);
}

class _StatChip extends StatelessWidget {
  final String label, value;
  final Color color;
  final bool isDark;
  const _StatChip(
      {required this.label,
      required this.value,
      required this.color,
      required this.isDark});
  @override
  Widget build(BuildContext context) => Expanded(
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.15))),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500)),
          ])));
}

class _ActiveRideCard extends StatelessWidget {
  final ride;
  final bool isDark;
  final VoidCallback onTap;
  const _ActiveRideCard(
      {required this.ride, required this.isDark, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.secondary.withOpacity(0.3))),
          child: Row(children: [
            Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.directions_car_rounded,
                    color: Colors.white, size: 20)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text('Active Ride',
                      style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(ride.destinationAddress,
                      style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(
                      '₦${ride.calculatedPrice.toStringAsFixed(0)} · ${ride.status}',
                      style: const TextStyle(
                          color: AppColors.textHint, fontSize: 11)),
                ])),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.secondary, size: 14),
          ])));
}

class _RecentRideCard extends StatelessWidget {
  final ride;
  final bool isDark;
  final VoidCallback onTap;
  const _RecentRideCard(
      {required this.ride, required this.isDark, required this.onTap});

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.directions_car_outlined,
                    color: AppColors.secondary, size: 18)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(ride.destinationAddress,
                      style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                      '₦${ride.calculatedPrice.toStringAsFixed(0)} · '
                      '${ride.distance.toStringAsFixed(1)} km',
                      style: const TextStyle(
                          color: AppColors.textHint, fontSize: 11)),
                ])),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: _statusColor(ride.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6)),
                child: Text(ride.status,
                    style: TextStyle(
                        color: _statusColor(ride.status),
                        fontSize: 10,
                        fontWeight: FontWeight.w700))),
          ])));
}
