// lib/features/ride/presentation/providers/ride_state.dart

import '../../domain/entities/ride_entity.dart';

enum RideStatus {
  idle, // no active ride
  creatingRide, // POST /rides in progress
  findingDriver, // ride created, polling for drivers
  driversFound, // at least one driver has responded
  cancelling, // cancel in progress
  error,
}

class RideState {
  final RideStatus status;
  final RideEntity? activeRide;
  final List<DriverInteractionEntity> driverOffers;
  final String? error;
  final List<RideEntity> rideHistory;
  final bool isLoadingHistory;

  const RideState({
    this.status = RideStatus.idle,
    this.activeRide,
    this.driverOffers = const [],
    this.error,
    this.rideHistory = const [],
    this.isLoadingHistory = false,
  });

  bool get hasActiveRide =>
      activeRide != null &&
      !['cancelled', 'completed', 'rejected'].contains(activeRide!.status);

  RideState copyWith({
    RideStatus? status,
    RideEntity? activeRide,
    List<DriverInteractionEntity>? driverOffers,
    String? error,
    List<RideEntity>? rideHistory,
    bool? isLoadingHistory,
    bool clearError = false,
    bool clearActiveRide = false,
  }) =>
      RideState(
        status: status ?? this.status,
        activeRide: clearActiveRide ? null : (activeRide ?? this.activeRide),
        driverOffers: driverOffers ?? this.driverOffers,
        error: clearError ? null : (error ?? this.error),
        rideHistory: rideHistory ?? this.rideHistory,
        isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      );
}
