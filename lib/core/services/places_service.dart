// lib/core/services/places_service.dart
//
// Uses Google Places REST API directly via Dio — no native SDK,
// no compilation issues. Works on both Android and iOS.

import 'package:dio/dio.dart';

class PlacesService {
  PlacesService._();
  static final PlacesService instance = PlacesService._();

  static const _apiKey = 'AIzaSyC8XivCLmCHmrRc7cP6bVH6nnVGcraLdjs';
  static const _baseUrl = 'https://maps.googleapis.com/maps/api/place';

  final _dio = Dio();

  /// Returns autocomplete predictions for [input], restricted to Nigeria.
  Future<List<PlacePrediction>> autocomplete(String input) async {
    if (input.trim().length < 3) return [];
    try {
      final response = await _dio.get(
        '$_baseUrl/autocomplete/json',
        queryParameters: {
          'input': input,
          'components': 'country:ng',
          'key': _apiKey,
          'language': 'en',
        },
      );
      final data = response.data as Map<String, dynamic>;
      final predictions = data['predictions'] as List<dynamic>? ?? [];
      return predictions
          .map((p) => PlacePrediction.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Fetches full place details (coordinates + address components) for [placeId].
  Future<PlaceDetail?> fetchPlace(String placeId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/details/json',
        queryParameters: {
          'place_id': placeId,
          'fields': 'geometry,address_components,formatted_address,name',
          'key': _apiKey,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final result = data['result'] as Map<String, dynamic>?;
      if (result == null) return null;
      return PlaceDetail.fromJson(result);
    } catch (_) {
      return null;
    }
  }

  /// Extracts state name from address components.
  String? extractState(PlaceDetail place) {
    for (final c in place.addressComponents) {
      if (c.types.contains('administrative_area_level_1')) {
        return c.longName
            .replaceAll(' State', '')
            .replaceAll(' state', '')
            .trim();
      }
    }
    return null;
  }

  /// Extracts LGA from address components.
  String? extractLga(PlaceDetail place) {
    for (final type in [
      'administrative_area_level_2',
      'sublocality_level_1',
      'locality',
    ]) {
      for (final c in place.addressComponents) {
        if (c.types.contains(type)) return c.longName;
      }
    }
    return null;
  }
}

// ── Data models ───────────────────────────────────────────────────────────────

class PlacePrediction {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final String fullText;

  const PlacePrediction({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    required this.fullText,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> j) {
    final structured =
        j['structured_formatting'] as Map<String, dynamic>? ?? {};
    return PlacePrediction(
      placeId: j['place_id']?.toString() ?? '',
      mainText: structured['main_text']?.toString() ?? '',
      secondaryText: structured['secondary_text']?.toString() ?? '',
      fullText: j['description']?.toString() ?? '',
    );
  }
}

class AddressComponent {
  final String longName;
  final String shortName;
  final List<String> types;

  const AddressComponent({
    required this.longName,
    required this.shortName,
    required this.types,
  });

  factory AddressComponent.fromJson(Map<String, dynamic> j) => AddressComponent(
        longName: j['long_name']?.toString() ?? '',
        shortName: j['short_name']?.toString() ?? '',
        types:
            (j['types'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
                [],
      );
}

class PlaceDetail {
  final String name;
  final String formattedAddress;
  final double lat;
  final double lng;
  final List<AddressComponent> addressComponents;

  const PlaceDetail({
    required this.name,
    required this.formattedAddress,
    required this.lat,
    required this.lng,
    required this.addressComponents,
  });

  factory PlaceDetail.fromJson(Map<String, dynamic> j) {
    final geometry = j['geometry'] as Map<String, dynamic>? ?? {};
    final location = geometry['location'] as Map<String, dynamic>? ?? {};
    final components = (j['address_components'] as List<dynamic>? ?? [])
        .map((c) => AddressComponent.fromJson(c as Map<String, dynamic>))
        .toList();
    return PlaceDetail(
      name: j['name']?.toString() ?? '',
      formattedAddress: j['formatted_address']?.toString() ?? '',
      lat: (location['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (location['lng'] as num?)?.toDouble() ?? 0.0,
      addressComponents: components,
    );
  }
}
