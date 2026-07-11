class NearbyDriverEntity {
  final String driverId;
  final double lat;
  final double lng;
  final double heading;
  final String vehicleType;
  const NearbyDriverEntity({required this.driverId, required this.lat, required this.lng, this.heading = 0, required this.vehicleType});
}
