// lib/features/dashboard/presentation/providers/dashboard_state.dart

import '../../domain/entities/dashboard_entity.dart';

class DashboardState {
  final bool isLoading;
  final DashboardEntity? data;
  final String? error;

  const DashboardState({
    this.isLoading = true,
    this.data,
    this.error,
  });

  // ── Convenience getters so the UI never has to drill through data?.x ────────
  RideStatsEntity? get stats => data?.stats;
  DashboardProfileEntity? get profile => data?.profile;

  // Direct field shortcuts used by home_page.dart
  String get firstName => data?.profile.firstName ?? '';
  String get fullName => data?.profile.fullName ?? '';
  String? get profilePicture => data?.profile.profilePicture;
  String get role => data?.profile.role ?? 'client';

  // Stats shortcuts — return 0 / 0.0 when not yet loaded
  int get totalRides => data?.stats.totalRides ?? 0;
  int get completed => data?.stats.completed ?? 0;
  int get cancelled => data?.stats.cancelled ?? 0;
  double get totalSpent => data?.stats.totalSpent ?? 0;
  double get completionRate => data?.stats.completionRate ?? 0;

  DashboardState copyWith({
    bool? isLoading,
    DashboardEntity? data,
    String? error,
    bool clearError = false,
  }) =>
      DashboardState(
        isLoading: isLoading ?? this.isLoading,
        data: data ?? this.data,
        error: clearError ? null : (error ?? this.error),
      );
}
