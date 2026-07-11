class FareEstimateEntity {
  final String vehicleTypeId;
  final double fare;
  final double distanceKm;
  final int durationSeconds;
  const FareEstimateEntity({required this.vehicleTypeId, required this.fare, required this.distanceKm, required this.durationSeconds});
}
