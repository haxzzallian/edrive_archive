class DriverEntity {
  final String id;
  final String name;
  final String phone;
  final String? avatarUrl;
  final double rating;
  final bool isOnline;
  final double totalEarnings;
  final int totalRides;
  final String? vehicleModel;
  final String? vehicleNumber;
  final String? vehicleColor;

  const DriverEntity({
    required this.id, required this.name, required this.phone,
    required this.rating, required this.isOnline,
    required this.totalEarnings, required this.totalRides,
    this.avatarUrl, this.vehicleModel, this.vehicleNumber, this.vehicleColor,
  });
}
