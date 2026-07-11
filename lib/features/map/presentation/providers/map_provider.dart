import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/location_service.dart';
import '../../domain/entities/nearby_driver_entity.dart';
import '../../domain/entities/place_entity.dart';
import '../../domain/usecases/get_nearby_drivers_usecase.dart';
import '../../domain/usecases/search_places_usecase.dart';

// ── Place Search ──────────────────────────────────────────────────────────────
final placeSearchQueryProvider = StateProvider<String>((ref) => '');

final placeSearchResultsProvider = FutureProvider<List<PlaceEntity>>((ref) async {
  final query = ref.watch(placeSearchQueryProvider);
  if (query.isEmpty) return [];
  final result = await getIt<SearchPlacesUseCase>()(query);
  return result.fold((f) => [], (list) => list);
});

// ── Nearby Drivers ────────────────────────────────────────────────────────────
final nearbyDriversProvider = FutureProvider<List<NearbyDriverEntity>>((ref) async {
  final pos = await LocationService.instance.getCurrentPosition();
  if (pos == null) return [];
  final result = await getIt<GetNearbyDriversUseCase>()(lat: pos.latitude, lng: pos.longitude);
  return result.fold((f) => [], (list) => list);
});

// ── Selected Locations ────────────────────────────────────────────────────────
final selectedPickupProvider  = StateProvider<PlaceEntity?>((ref) => null);
final selectedDropoffProvider = StateProvider<PlaceEntity?>((ref) => null);
