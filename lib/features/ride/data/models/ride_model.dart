// lib/features/ride/data/models/ride_model.dart

import '../../domain/entities/ride_entity.dart';

class RideCoordinatesModel {
  final double lat;
  final double lng;
  const RideCoordinatesModel({required this.lat, required this.lng});

  factory RideCoordinatesModel.fromJson(Map<String, dynamic> j) =>
      RideCoordinatesModel(
        lat: (j['lat'] as num?)?.toDouble() ?? 0.0,
        lng: (j['lng'] as num?)?.toDouble() ?? 0.0,
      );

  RideCoordinatesEntity toEntity() => RideCoordinatesEntity(lat: lat, lng: lng);
}

class DriverInteractionModel {
  final String driverId;
  final String driverName;
  final double? offeredPrice;
  final String status;

  const DriverInteractionModel({
    required this.driverId,
    required this.driverName,
    this.offeredPrice,
    required this.status,
  });

  factory DriverInteractionModel.fromJson(Map<String, dynamic> j) {
    // driverInteractions can have varying shapes depending on endpoint
    final driver = j['driver'];
    String driverId = '';
    String driverName = '';
    if (driver is Map) {
      driverId = driver['_id']?.toString() ?? '';
      final first = driver['firstName']?.toString() ?? '';
      final last = driver['lastName']?.toString() ?? '';
      driverName = '$first $last'.trim();
    } else if (driver is String) {
      driverId = driver;
    }

    return DriverInteractionModel(
      driverId: j['driverId']?.toString() ?? driverId,
      driverName: j['driverName']?.toString() ?? driverName,
      offeredPrice: (j['offeredPrice'] ?? j['price'] as num?)?.toDouble(),
      status: j['status']?.toString() ?? 'pending',
    );
  }

  DriverInteractionEntity toEntity() => DriverInteractionEntity(
        driverId: driverId,
        driverName: driverName,
        offeredPrice: offeredPrice,
        status: status,
      );
}

class RideModel {
  final String id;
  final String pickupAddress;
  final String destinationAddress;
  final RideCoordinatesModel pickupCoordinates;
  final RideCoordinatesModel destinationCoordinates;
  final double calculatedPrice;
  final double? desiredPrice;
  final int passengerNum;
  final double distance;
  final String rideOption;
  final String paymentMethod;
  final String status;
  final String? cancelledBy;
  final String? cancellationReason;
  final List<DriverInteractionModel> driverInteractions;
  final DateTime createdAt;

  const RideModel({
    required this.id,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.pickupCoordinates,
    required this.destinationCoordinates,
    required this.calculatedPrice,
    this.desiredPrice,
    required this.passengerNum,
    required this.distance,
    required this.rideOption,
    required this.paymentMethod,
    required this.status,
    this.cancelledBy,
    this.cancellationReason,
    this.driverInteractions = const [],
    required this.createdAt,
  });

  factory RideModel.fromJson(Map<String, dynamic> j) {
    final interactions = (j['driverInteractions'] as List<dynamic>? ?? [])
        .map((e) => DriverInteractionModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return RideModel(
      id: j['_id']?.toString() ?? j['rideId']?.toString() ?? '',
      pickupAddress: j['pickupAddress']?.toString() ?? '',
      destinationAddress: j['destinationAddress']?.toString() ?? '',
      pickupCoordinates: RideCoordinatesModel.fromJson(
          j['pickupCoordinates'] as Map<String, dynamic>? ?? {}),
      destinationCoordinates: RideCoordinatesModel.fromJson(
          j['destinationCoordinates'] as Map<String, dynamic>? ?? {}),
      calculatedPrice: (j['calculatedPrice'] as num?)?.toDouble() ?? 0,
      desiredPrice: (j['desiredPrice'] as num?)?.toDouble(),
      passengerNum: (j['passengerNum'] as num?)?.toInt() ?? 1,
      distance: (j['distance'] as num?)?.toDouble() ?? 0,
      rideOption: j['rideOption']?.toString() ?? 'economy',
      paymentMethod: j['paymentMethod']?.toString() ?? 'cash',
      status: j['status']?.toString() ?? 'pending',
      cancelledBy: j['cancelledBy']?.toString(),
      cancellationReason: j['cancellationReason']?.toString(),
      driverInteractions: interactions,
      createdAt:
          DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  RideEntity toEntity() => RideEntity(
        id: id,
        pickupAddress: pickupAddress,
        destinationAddress: destinationAddress,
        pickupCoordinates: pickupCoordinates.toEntity(),
        destinationCoordinates: destinationCoordinates.toEntity(),
        calculatedPrice: calculatedPrice,
        desiredPrice: desiredPrice,
        passengerNum: passengerNum,
        distance: distance,
        rideOption: rideOption,
        paymentMethod: paymentMethod,
        status: status,
        cancelledBy: cancelledBy,
        cancellationReason: cancellationReason,
        driverInteractions:
            driverInteractions.map((e) => e.toEntity()).toList(),
        createdAt: createdAt,
      );
}
