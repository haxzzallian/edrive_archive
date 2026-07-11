// lib/features/auth/presentation/widgets/map_animation_background.dart
//
// Shared widget used by LoginPage and RegisterPage.
// Renders an animated map with cars moving across the screen,
// identical to the onboarding illustration style.

import 'dart:math';
import 'package:flutter/material.dart';

class MapAnimationBackground extends StatefulWidget {
  /// Fraction of screen height this widget should occupy.
  /// Login uses 0.38, Register uses the full header height (180px).
  final double? height;

  /// Optional overlay gradient drawn on top of the map.
  /// Defaults to a dark bottom fade matching the header style.
  final List<Color>? overlayColors;

  /// Border radius for the container. Pass null for no radius.
  final BorderRadius? borderRadius;

  const MapAnimationBackground({
    super.key,
    this.height,
    this.overlayColors,
    this.borderRadius,
  });

  @override
  State<MapAnimationBackground> createState() => _MapAnimationBackgroundState();
}

class _MapAnimationBackgroundState extends State<MapAnimationBackground>
    with TickerProviderStateMixin {
  // Each car has its own controller so speeds are independent
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  static const _carConfigs = [
    // (yFraction, size, durationSeconds, delaySeconds)
    (0.12, 42.0, 14, 0.0),
    (0.28, 32.0, 18, 2.5),
    (0.48, 38.0, 12, 5.0),
    (0.65, 28.0, 16, 1.2),
    (0.80, 36.0, 20, 3.8),
  ];

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(_carConfigs.length, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(seconds: _carConfigs[i].$3),
      );
    });

    _animations = _controllers.map((c) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(c);
    }).toList();

    // Stagger starts so cars don't all enter at once
    for (int i = 0; i < _controllers.length; i++) {
      final delay = (_carConfigs[i].$4 * 1000).round();
      Future.delayed(Duration(milliseconds: delay), () {
        if (mounted) _controllers[i].repeat();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final h = widget.height ?? size.height * 0.38;

    final overlay =
        widget.overlayColors ?? [Colors.transparent, const Color(0xCC0D1B2A)];

    Widget content = Stack(
      children: [
        // ── Map ─────────────────────────────────────────────────────────────
        Positioned.fill(
          child: CustomPaint(painter: _MapPainter()),
        ),

        // ── Gradient overlay ─────────────────────────────────────────────────
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: overlay,
              ),
            ),
          ),
        ),

        // ── Animated cars ────────────────────────────────────────────────────
        ...List.generate(_carConfigs.length, (i) {
          final cfg = _carConfigs[i];
          return _AnimatedCar(
            animation: _animations[i],
            yFraction: cfg.$1,
            size: cfg.$2,
            containerHeight: h,
            screenWidth: size.width,
          );
        }),
      ],
    );

    // Clip to border radius if provided
    if (widget.borderRadius != null) {
      content = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: content,
      );
    }

    return SizedBox(height: h, child: content);
  }
}

// ── Single animated car ───────────────────────────────────────────────────────
class _AnimatedCar extends StatelessWidget {
  final Animation<double> animation;
  final double yFraction;
  final double size;
  final double containerHeight;
  final double screenWidth;

  const _AnimatedCar({
    required this.animation,
    required this.yFraction,
    required this.size,
    required this.containerHeight,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        // Travel from off-screen left (-size) to off-screen right (screenWidth + size)
        final x = -size + (screenWidth + size * 2) * animation.value;
        // Gentle vertical bob
        final bob = sin(animation.value * 2 * pi) * 4.0;
        final y = yFraction * containerHeight + bob - size / 2;

        return Positioned(
          left: x,
          top: y,
          child: Icon(
            Icons.directions_car_rounded,
            size: size,
            color: const Color(0xFFFFAB00), // AppColors.accent
          ),
        );
      },
    );
  }
}

// ── Map painter — same style as onboarding ────────────────────────────────────
class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Base map colour
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFD4E6C3),
    );

    // Water
    final water = Paint()..color = const Color(0xFF9DC3D4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.35, h * 0.15, w * 0.30, h * 0.20),
          const Radius.circular(8)),
      water,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(-w * 0.04, h * 0.55, w * 0.22, h * 0.30),
          const Radius.circular(6)),
      water,
    );

    // Parks
    final park = Paint()..color = const Color(0xFF8BBD6B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.06, h * 0.05, w * 0.16, h * 0.18),
          const Radius.circular(6)),
      park,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.68, h * 0.45, w * 0.20, h * 0.18),
          const Radius.circular(6)),
      park,
    );

    // City blocks
    final block = Paint()..color = const Color(0xFFBFCFBF);
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 4; col++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(
                w * 0.08 + col * w * 0.23,
                h * 0.08 + row * h * 0.20,
                w * 0.14,
                h * 0.12,
              ),
              const Radius.circular(3)),
          block,
        );
      }
    }

    // Roads — horizontal
    final road = Paint()
      ..color = const Color(0xFFE8E0D0)
      ..strokeWidth = 10;
    for (int i = 0; i < 6; i++) {
      final y = h * (0.08 + i * 0.18);
      canvas.drawLine(Offset(0, y), Offset(w, y), road);
    }

    // Roads — vertical
    for (int i = 0; i < 5; i++) {
      final x = w * (0.10 + i * 0.22);
      canvas.drawLine(Offset(x, 0), Offset(x, h), road);
    }

    // Road centre dashes
    final dash = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..strokeWidth = 1.5;
    for (int i = 0; i < 6; i++) {
      final y = h * (0.08 + i * 0.18);
      for (double x = 0; x < w; x += 22) {
        canvas.drawLine(Offset(x, y), Offset(x + 10, y), dash);
      }
    }

    // Location pin
    final pin = Paint()..color = const Color(0xFFCC2222);
    final px = w * 0.72;
    final py = h * 0.35;
    canvas.drawCircle(Offset(px, py), 18, pin);
    canvas.drawPath(
      Path()
        ..moveTo(px, py + 18)
        ..lineTo(px - 10, py + 34)
        ..lineTo(px + 10, py + 34)
        ..close(),
      pin,
    );
    canvas.drawCircle(Offset(px, py), 8, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
