// lib/features/ride/domain/entities/ride_entity.dart

class RideCoordinatesEntity {
  final double lat;
  final double lng;
  const RideCoordinatesEntity({required this.lat, required this.lng});
}

class DriverInteractionEntity {
  final String driverId;
  final String driverName;
  final double? offeredPrice;
  final String status; // 'pending' | 'accepted' | 'rejected'
  const DriverInteractionEntity({
    required this.driverId,
    required this.driverName,
    this.offeredPrice,
    required this.status,
  });
}

class RideEntity {
  final String id;
  final String pickupAddress;
  final String destinationAddress;
  final RideCoordinatesEntity pickupCoordinates;
  final RideCoordinatesEntity destinationCoordinates;
  final double calculatedPrice;
  final double? desiredPrice;
  final int passengerNum;
  final double distance;
  final String rideOption;
  final String paymentMethod;
  final String status;
  final String? cancelledBy;
  final String? cancellationReason;
  final List<DriverInteractionEntity> driverInteractions;
  final DateTime createdAt;

  const RideEntity({
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

  bool get isPending => status == 'pending';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';
  bool get hasDrivers => driverInteractions.isNotEmpty;
}

class CreateRideParams {
  final String pickupAddress;
  final String destinationAddress;
  final RideCoordinatesEntity pickupCoordinates;
  final RideCoordinatesEntity destinationCoordinates;
  final String rideOption;
  final String paymentMethod;
  final int passengerNum;
  final double? desiredPrice;

  const CreateRideParams({
    required this.pickupAddress,
    required this.destinationAddress,
    required this.pickupCoordinates,
    required this.destinationCoordinates,
    required this.rideOption,
    required this.paymentMethod,
    required this.passengerNum,
    this.desiredPrice,
  });
}
