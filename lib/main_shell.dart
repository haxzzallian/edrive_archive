// lib/main_shell.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_colors.dart';
import 'core/services/token_storage.dart';

class MainShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({super.key, required this.navigationShell});
  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with TickerProviderStateMixin {
  bool get _isDriver => TokenStorage.instance.isDriver;

  // One controller per tab for the bounce animation on tap
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _scaleAnims;

  @override
  void initState() {
    super.initState();
    final count = _isDriver ? 4 : 3;
    _controllers = List.generate(
        count,
        (i) => AnimationController(
            vsync: this, duration: const Duration(milliseconds: 300)));
    _scaleAnims = _controllers
        .map((c) => TweenSequence<double>([
              TweenSequenceItem(
                  tween: Tween(begin: 1.0, end: 0.78), weight: 40),
              TweenSequenceItem(
                  tween: Tween(begin: 0.78, end: 1.12), weight: 35),
              TweenSequenceItem(
                  tween: Tween(begin: 1.12, end: 1.0), weight: 25),
            ]).animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();
    // Animate the initially selected tab
    _controllers[widget.navigationShell.currentIndex].forward();
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    HapticFeedback.lightImpact();
    _controllers[index].forward(from: 0);
    widget.navigationShell.goBranch(index,
        initialLocation: index == widget.navigationShell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = widget.navigationShell.currentIndex;

    final items = [
      _NavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home_rounded,
          label: 'Home'),
      _NavItem(
          icon: Icons.history_outlined,
          activeIcon: Icons.history_rounded,
          label: 'Trips'),
      if (_isDriver)
        _NavItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard_rounded,
            label: 'Dashboard'),
      _NavItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person_rounded,
          label: 'Profile'),
    ];

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: _FantasticNavBar(
        items: items,
        selectedIndex: selected,
        isDark: isDark,
        scaleAnims: _scaleAnims,
        onTap: _onTap,
      ),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────
class _NavItem {
  final IconData icon, activeIcon;
  final String label;
  const _NavItem(
      {required this.icon, required this.activeIcon, required this.label});
}

// ── The bar itself ────────────────────────────────────────────────────────────
class _FantasticNavBar extends StatelessWidget {
  final List<_NavItem> items;
  final int selectedIndex;
  final bool isDark;
  final List<Animation<double>> scaleAnims;
  final void Function(int) onTap;

  const _FantasticNavBar({
    required this.items,
    required this.selectedIndex,
    required this.isDark,
    required this.scaleAnims,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF1A1A2E) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        // Subtle top border + shadow
        boxShadow: [
          BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.5)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
                items.length,
                (i) => _NavTile(
                      item: items[i],
                      isSelected: i == selectedIndex,
                      isDark: isDark,
                      scaleAnim: scaleAnims[i],
                      onTap: () => onTap(i),
                    )),
          ),
        ),
      ),
    );
  }
}

// ── Individual tile ───────────────────────────────────────────────────────────
class _NavTile extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final bool isDark;
  final Animation<double> scaleAnim;
  final VoidCallback onTap;

  const _NavTile({
    required this.item,
    required this.isSelected,
    required this.isDark,
    required this.scaleAnim,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: scaleAnim,
        builder: (_, child) =>
            Transform.scale(scale: scaleAnim.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 18 : 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            // Glow effect on selected
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: AppColors.secondary.withOpacity(0.35),
                        blurRadius: 16,
                        spreadRadius: 0,
                        offset: const Offset(0, 4)),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  key: ValueKey(isSelected),
                  size: 22,
                  color: isSelected
                      ? Colors.white
                      : isDark
                          ? Colors.white.withOpacity(0.45)
                          : Colors.black.withOpacity(0.4),
                ),
              ),
              // Label — slides in when selected
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: isSelected
                    ? Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(item.label,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2)))
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
