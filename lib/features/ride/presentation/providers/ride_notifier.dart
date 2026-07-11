// lib/features/ride/presentation/providers/ride_notifier.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/ride_entity.dart';
import '../../domain/usecases/ride_usecases.dart';
import 'ride_state.dart';

class RideNotifier extends StateNotifier<RideState> {
  final CreateRideUseCase _createRide;
  final GetClientRidesUseCase _getClientRides;
  final GetRideChatUseCase _getRideChat;
  final CancelRideUseCase _cancelRide;

  Timer? _pollTimer;

  // Poll every 5 seconds — same pattern as web (continuous loop)
  static const _pollInterval = Duration(seconds: 5);

  RideNotifier(
    this._createRide,
    this._getClientRides,
    this._getRideChat,
    this._cancelRide,
  ) : super(const RideState());

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }

  void clearError() => state = state.copyWith(clearError: true);

  // ── Create ride ────────────────────────────────────────────────────────────
  // POST /rides — returns ride with calculatedPrice + distance
  Future<bool> createRide(CreateRideParams params) async {
    state = state.copyWith(status: RideStatus.creatingRide, clearError: true);

    final result = await _createRide(params);
    return result.fold(
      (failure) {
        state = state.copyWith(status: RideStatus.idle, error: failure.message);
        return false;
      },
      (ride) {
        state = state.copyWith(
          status: RideStatus.findingDriver,
          activeRide: ride,
        );
        // Start polling for drivers immediately after ride is created
        _startPolling(ride.id);
        return true;
      },
    );
  }

  // ── Polling ────────────────────────────────────────────────────────────────
  // Mirrors web behaviour: poll /rides/client + /rides/:id/chat in a loop
  void _startPolling(String rideId) {
    _stopPolling();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _poll(rideId));
    // Poll immediately on start
    _poll(rideId);
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _poll(String rideId) async {
    // Don't poll if we're in the middle of something else
    if (state.status == RideStatus.cancelling ||
        state.status == RideStatus.idle) return;

    // 1. GET /rides/client — check ride status
    final ridesResult = await _getClientRides();
    ridesResult.fold(
      (_) {}, // silent fail on poll
      (rides) {
        final active = rides.firstWhere(
          (r) => r.id == rideId,
          orElse: () => state.activeRide!,
        );
        // If ride was cancelled externally or completed, stop polling
        if (['cancelled', 'completed', 'rejected'].contains(active.status)) {
          _stopPolling();
          state = state.copyWith(
            status: RideStatus.idle,
            activeRide: active,
            clearActiveRide: false,
          );
          return;
        }
        state = state.copyWith(activeRide: active);
      },
    );

    // 2. GET /rides/:id/chat — check driver offers
    final chatResult = await _getRideChat(rideId);
    chatResult.fold(
      (_) {}, // silent fail on poll
      (offers) {
        if (offers.isNotEmpty) {
          state = state.copyWith(
            status: RideStatus.driversFound,
            driverOffers: offers,
          );
          // Don't stop polling — more drivers may respond
        }
      },
    );
  }

  // ── Cancel ride ────────────────────────────────────────────────────────────
  Future<bool> cancelRide() async {
    final rideId = state.activeRide?.id;
    if (rideId == null) return false;

    _stopPolling();
    state = state.copyWith(status: RideStatus.cancelling, clearError: true);

    final result = await _cancelRide(rideId);
    return result.fold(
      (failure) {
        state = state.copyWith(
          status: RideStatus.findingDriver,
          error: failure.message,
        );
        // Restart polling if cancel failed
        _startPolling(rideId);
        return false;
      },
      (ride) {
        state = state.copyWith(
          status: RideStatus.idle,
          activeRide: ride,
          driverOffers: [],
        );
        return true;
      },
    );
  }

  // ── Load ride history ──────────────────────────────────────────────────────
  Future<void> loadHistory() async {
    state = state.copyWith(isLoadingHistory: true);
    final result = await _getClientRides();
    result.fold(
      (failure) => state =
          state.copyWith(isLoadingHistory: false, error: failure.message),
      (rides) =>
          state = state.copyWith(isLoadingHistory: false, rideHistory: rides),
    );
  }

  // ── Resume polling if app comes back to foreground with active ride ────────
  void resumeIfActive() {
    final ride = state.activeRide;
    if (ride != null && ride.isPending && _pollTimer == null) {
      state = state.copyWith(status: RideStatus.findingDriver);
      _startPolling(ride.id);
    }
  }
}

final rideProvider = StateNotifierProvider<RideNotifier, RideState>(
  (ref) => RideNotifier(
    getIt<CreateRideUseCase>(),
    getIt<GetClientRidesUseCase>(),
    getIt<GetRideChatUseCase>(),
    getIt<CancelRideUseCase>(),
  ),
);
