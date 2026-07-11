// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand Core ─────────────────────────────────────────────────────────────
  static const primary = Color(0xFF0D1B2A); // near-black navy
  static const secondary = Color(0xFF2ECC40); // brand green
  static const accent = Color(0xFFFFAB00); // golden amber (cars/icons)

  // ── Light Mode ─────────────────────────────────────────────────────────────
  static const background = Color(0xFFF6F7F9);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFEEEFF3);
  static const surfaceElevated = Color(0xFFFFFFFF);
  static const divider = Color(0xFFE5E7EB);

  // ── Dark Mode ──────────────────────────────────────────────────────────────
  static const darkBackground = Color(0xFF0D1117);
  static const darkSurface = Color(0xFF161B22);
  static const darkSurfaceVariant = Color(0xFF21262D);
  static const darkSurfaceElevated = Color(0xFF2D333B);
  static const darkDivider = Color(0xFF30363D);

  // ── Text — Light ───────────────────────────────────────────────────────────
  static const textPrimary = Color(0xFF0D1B2A);
  static const textSecondary = Color(0xFF6B7280);
  static const textHint = Color(0xFF9CA3AF);
  static const textOnDark = Color(0xFFFFFFFF);
  static const textOnDarkMuted = Color(0xCCFFFFFF);

  // ── Text — Dark ────────────────────────────────────────────────────────────
  static const darkTextPrimary = Color(0xFFE6EDF3);
  static const darkTextSecondary = Color(0xFF8B949E);
  static const darkTextHint = Color(0xFF6E7681);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const success = Color(0xFF2ECC40);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFFF9800);
  static const info = Color(0xFF2196F3);

  // ── Ride States ────────────────────────────────────────────────────────────
  static const driverOnline = Color(0xFF2ECC40);
  static const driverOffline = Color(0xFF9CA3AF);
  static const ridePending = Color(0xFFFFAB00);
  static const rideActive = Color(0xFF2ECC40);
  static const rideCancelled = Color(0xFFEF4444);
  static const rideCompleted = Color(0xFF0D1B2A);

  // ── Map ────────────────────────────────────────────────────────────────────
  static const mapOverlay = Color(0x800D1B2A);
  static const mapPin = Color(0xFFEF4444);
  static const mapPinShadow = Color(0x40EF4444);

  // ── Gradients ──────────────────────────────────────────────────────────────
  static const List<Color> splashGradient = [
    Color(0x33000000),
    Color(0x88000000),
    Color(0xCC000000),
  ];

  static const List<Color> greenGradient = [
    Color(0xFF2ECC40),
    Color(0xFF00A821),
  ];

  static const List<Color> darkGreenGradient = [
    Color(0xFF1A7A28),
    Color(0xFF0D5C1A),
  ];

  // ── Helper: context-aware getters ─────────────────────────────────────────
  static Color bg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkBackground
          : background;

  static Color surf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurface : surface;

  static Color surfVar(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkSurfaceVariant
          : surfaceVariant;

  static Color txtPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkTextPrimary
          : textPrimary;

  static Color txtSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkTextSecondary
          : textSecondary;
}
