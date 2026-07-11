import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/usecases/go_online_usecase.dart';
import '../../domain/usecases/go_offline_usecase.dart';
import '../../domain/usecases/get_driver_earnings_usecase.dart';
import '../../domain/entities/earnings_entity.dart';

class DriverOnlineState {
  final bool isOnline;
  final bool isLoading;
  final String? error;
  const DriverOnlineState({this.isOnline = false, this.isLoading = false, this.error});
  DriverOnlineState copyWith({bool? isOnline, bool? isLoading, String? error}) =>
    DriverOnlineState(isOnline: isOnline ?? this.isOnline, isLoading: isLoading ?? this.isLoading, error: error);
}

class DriverOnlineNotifier extends StateNotifier<DriverOnlineState> {
  final GoOnlineUseCase _goOnline;
  final GoOfflineUseCase _goOffline;

  DriverOnlineNotifier(this._goOnline, this._goOffline) : super(const DriverOnlineState());

  Future<void> toggleOnline({double lat = 6.5244, double lng = 3.3792}) async {
    state = state.copyWith(isLoading: true, error: null);
    if (state.isOnline) {
      final result = await _goOffline();
      result.fold(
        (f) => state = state.copyWith(isLoading: false, error: f.message),
        (_) => state = state.copyWith(isLoading: false, isOnline: false),
      );
    } else {
      final result = await _goOnline(lat: lat, lng: lng);
      result.fold(
        (f) => state = state.copyWith(isLoading: false, error: f.message),
        (_) => state = state.copyWith(isLoading: false, isOnline: true),
      );
    }
  }
}

final driverOnlineProvider = StateNotifierProvider<DriverOnlineNotifier, DriverOnlineState>(
  (ref) => DriverOnlineNotifier(getIt<GoOnlineUseCase>(), getIt<GoOfflineUseCase>()),
);

final earningsProvider = FutureProvider<EarningsEntity>((ref) async {
  final result = await getIt<GetDriverEarningsUseCase>()();
  return result.fold((f) => throw f.message, (e) => e);
});
