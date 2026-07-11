// lib/core/widgets/app_drawer.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../router/app_routes.dart';
import '../services/token_storage.dart';
import '../theme/app_colors.dart';
import '../../features/auth/presentation/providers/auth_notifier.dart';

class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({super.key});
  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  // Track which expandable sections are open
  bool _exploreOpen = false;
  bool _moreOpen = false;
  bool _repairOpen = false;
  bool _deliveryOpen = false;

  void _close() => Navigator.of(context).pop();

  void _navigate(String route) {
    _close();
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firstName = TokenStorage.instance.name?.split(' ').first ?? 'User';
    final fullName = TokenStorage.instance.name ?? 'User';

    return Drawer(
      backgroundColor:
          isDark ? const Color(0xFF0F1923) : const Color(0xFF1A7A3C),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(0), bottomRight: Radius.circular(0))),
      child: Column(children: [
        // ── Header ──────────────────────────────────────────────────────────
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Row(children: [
              Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.directions_car_rounded,
                      color: Color(0xFF1A7A3C), size: 28)),
              const SizedBox(width: 12),
              const Text('EDrive',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5)),
            ]),
          ),
        ),

        // ── Nav items ────────────────────────────────────────────────────────
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _Item(
                  icon: Icons.bar_chart_rounded,
                  label: 'Dashboard',
                  isActive: true,
                  onTap: () {
                    _close();
                    context.go(AppRoutes.driverDash);
                  }),
              _Item(
                  icon: Icons.directions_car_rounded,
                  label: 'Book a Ride',
                  onTap: () => _navigate(AppRoutes.bookRide)),
              _Item(
                  icon: Icons.flight_rounded,
                  label: 'Airport Pickup/Dropoff',
                  onTap: _close),
              _Item(
                  icon: Icons.local_taxi_rounded,
                  label: 'Airport Booked Ride',
                  onTap: _close),
              _Item(
                  icon: Icons.history_rounded,
                  label: 'History',
                  onTap: () {
                    _close();
                    context.go(AppRoutes.trips);
                  }),
              _Item(
                  icon: Icons.car_crash_rounded,
                  label: 'My Breakdown',
                  onTap: _close),
              _Item(
                  icon: Icons.person_search_rounded,
                  label: 'Hire a Driver?',
                  onTap: _close),

              const SizedBox(height: 4),
              _Divider(),

              // ── Explore ───────────────────────────────────────────────────
              _ExpandableSection(
                icon: Icons.explore_rounded,
                label: 'Explore',
                isOpen: _exploreOpen,
                onTap: () => setState(() => _exploreOpen = !_exploreOpen),
                children: [
                  _SubItem(
                      icon: Icons.directions_car_filled_rounded,
                      label: 'E-Driver',
                      onTap: () {
                        _close();
                        context.push(AppRoutes.webview, extra: {
                          'url': 'https://edrivers.ng',
                          'title': 'E-Driver',
                        });
                      }),
                  _SubItem(
                      icon: Icons.build_circle_rounded,
                      label: 'E-Fixit',
                      onTap: () {
                        _close();
                        context.push(AppRoutes.webview, extra: {
                          'url': 'https://efixit.ng',
                          'title': 'E-Fixit',
                        });
                      }),
                ],
              ),

              // ── More ──────────────────────────────────────────────────────
              _ExpandableSection(
                icon: Icons.add_circle_outline_rounded,
                label: 'More',
                isOpen: _moreOpen,
                onTap: () => setState(() => _moreOpen = !_moreOpen),
                children: [
                  _SubItem(
                      icon: Icons.car_rental_rounded,
                      label: 'Rent your vehicle?',
                      onTap: _close),
                  _SubItem(
                      icon: Icons.directions_car_outlined,
                      label: 'Rent a car',
                      onTap: _close),
                ],
              ),

              // ── Repair & Maintenance ──────────────────────────────────────
              _ExpandableSection(
                icon: Icons.build_rounded,
                label: 'Repair & Maintenance',
                isOpen: _repairOpen,
                onTap: () => setState(() => _repairOpen = !_repairOpen),
                children: [
                  _SubItem(
                      icon: Icons.engineering_rounded,
                      label: 'Get a Mechanic?',
                      onTap: _close),
                  _SubItem(
                      icon: Icons.electrical_services_rounded,
                      label: 'Get an Electrician?',
                      onTap: _close),
                  _SubItem(
                      icon: Icons.settings_rounded,
                      label: 'Get a Car Part?',
                      onTap: _close),
                ],
              ),

              // ── Delivery & Logistics ──────────────────────────────────────
              _ExpandableSection(
                icon: Icons.local_shipping_rounded,
                label: 'Delivery & Logistics',
                isOpen: _deliveryOpen,
                onTap: () => setState(() => _deliveryOpen = !_deliveryOpen),
                children: [
                  _SubItem(
                      icon: Icons.fire_truck_rounded,
                      label: 'Rent a Truck?',
                      onTap: _close),
                  _SubItem(
                      icon: Icons.receipt_long_rounded,
                      label: 'My Rental Activity?',
                      onTap: _close),
                  _SubItem(
                      icon: Icons.people_rounded,
                      label: 'My Clients',
                      onTap: _close),
                ],
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),

        // ── Footer — profile + logout ────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(
                      color: Colors.white.withOpacity(0.15), width: 1))),
          child: Column(children: [
            // Profile row
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: Text(
                    fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                        color: Color(0xFF1A7A3C),
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
              ),
              title: Text(fullName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              subtitle: Text(TokenStorage.instance.role ?? '',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
              onTap: () => _navigate(AppRoutes.profile),
            ),
            // Logout
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              leading: const Icon(Icons.logout_rounded,
                  color: Colors.redAccent, size: 20),
              title: const Text('Logout',
                  style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              onTap: () async {
                _close();
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go(AppRoutes.login);
              },
            ),
            const SizedBox(height: 8),
          ]),
        ),
      ]),
    );
  }
}

// ── Nav item ──────────────────────────────────────────────────────────────────
class _Item extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _Item(
      {required this.icon,
      required this.label,
      this.isActive = false,
      required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          splashColor: Colors.white.withOpacity(0.1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
                color: isActive
                    ? Colors.white.withOpacity(0.18)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 14),
              Text(label,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.w500)),
              if (isActive) ...[
                const Spacer(),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Text('Stop',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600))),
              ],
            ]),
          ),
        ),
      );
}

// ── Sub-item (indented) ───────────────────────────────────────────────────────
class _SubItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SubItem(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 9, 14, 9),
            child: Row(children: [
              Icon(icon, color: Colors.white.withOpacity(0.75), size: 16),
              const SizedBox(width: 12),
              Text(label,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w400)),
            ]),
          ),
        ),
      );
}

// ── Expandable section ────────────────────────────────────────────────────────
class _ExpandableSection extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isOpen;
  final VoidCallback onTap;
  final List<Widget> children;
  const _ExpandableSection(
      {required this.icon,
      required this.label,
      required this.isOpen,
      required this.onTap,
      required this.children});

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                  color: isOpen
                      ? Colors.white.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 14),
                Expanded(
                    child: Text(label,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500))),
                AnimatedRotation(
                    turns: isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.white, size: 20)),
              ]),
            ),
          ),
        ),
        // Animated expand/collapse
        AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
                margin: const EdgeInsets.only(left: 8, bottom: 4),
                decoration: BoxDecoration(
                    border: Border(
                        left: BorderSide(
                            color: Colors.white.withOpacity(0.2), width: 1.5))),
                child: Column(children: children)),
            crossFadeState:
                isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220)),
      ]);
}

// ── Divider ───────────────────────────────────────────────────────────────────
class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Divider(color: Colors.white.withOpacity(0.15), height: 1));
}
