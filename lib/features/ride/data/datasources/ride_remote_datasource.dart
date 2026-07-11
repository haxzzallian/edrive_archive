// lib/features/ride/data/datasources/ride_remote_datasource.dart

import '../../../../core/network/dio_client.dart';
import '../models/ride_model.dart';
import '../../domain/entities/ride_entity.dart';

abstract class RideRemoteDataSource {
  Future<RideModel> createRide(CreateRideParams params);
  Future<List<RideModel>> getClientRides();
  Future<List<DriverInteractionModel>> getRideChat(String rideId);
  Future<RideModel> cancelRide(String rideId);
}

class RideRemoteDataSourceImpl implements RideRemoteDataSource {
  final DioClient _client;
  RideRemoteDataSourceImpl(this._client);

  // POST /rides
  // Body: { pickupAddress, destinationAddress, pickupCoordinates,
  //         destinationCoordinates, rideOption, paymentMethod,
  //         passengerNum, desiredPrice? }
  // Response: { success, ride: { ... }, fare: { distance, calculatedPrice } }
  @override
  Future<RideModel> createRide(CreateRideParams params) async {
    final response = await _client.dio.post('/rides', data: {
      'pickupAddress': params.pickupAddress,
      'destinationAddress': params.destinationAddress,
      'pickupCoordinates': {
        'lat': params.pickupCoordinates.lat,
        'lng': params.pickupCoordinates.lng,
      },
      'destinationCoordinates': {
        'lat': params.destinationCoordinates.lat,
        'lng': params.destinationCoordinates.lng,
      },
      'rideOption': params.rideOption,
      'paymentMethod': params.paymentMethod,
      'passengerNum': params.passengerNum,
      if (params.desiredPrice != null) 'desiredPrice': params.desiredPrice,
    });
    final data = response.data as Map<String, dynamic>;
    // Merge fare into ride so calculatedPrice + distance are available
    final rideJson =
        Map<String, dynamic>.from(data['ride'] as Map<String, dynamic>);
    final fare = data['fare'] as Map<String, dynamic>? ?? {};
    rideJson['calculatedPrice'] ??= fare['calculatedPrice'];
    rideJson['distance'] ??= fare['distance'];
    return RideModel.fromJson(rideJson);
  }

  // GET /rides/client
  // Response: [ { ... ride ... }, ... ]
  @override
  Future<List<RideModel>> getClientRides() async {
    final response = await _client.dio.get('/rides/client');
    final data = response.data;
    if (data is List) {
      return data
          .map((e) => RideModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // GET /rides/:id/chat
  // Response: array of driver interaction objects
  @override
  Future<List<DriverInteractionModel>> getRideChat(String rideId) async {
    final response = await _client.dio.get('/rides/$rideId/chat');
    final data = response.data;
    if (data is List) {
      return data
          .map(
              (e) => DriverInteractionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    // Some endpoints wrap in object
    if (data is Map && data['interactions'] is List) {
      return (data['interactions'] as List)
          .map(
              (e) => DriverInteractionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // POST /rides/:id/cancel
  // Body: { rideId }
  // Response: { success, ride: { ... } }
  @override
  Future<RideModel> cancelRide(String rideId) async {
    final response = await _client.dio.post(
      '/rides/$rideId/cancel',
      data: {'rideId': rideId},
    );
    final data = response.data as Map<String, dynamic>;
    return RideModel.fromJson(data['ride'] as Map<String, dynamic>);
  }
}
