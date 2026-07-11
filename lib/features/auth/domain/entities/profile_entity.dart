// lib/features/profile_setup/domain/entities/profile_entity.dart

class LocationEntity {
  final String state;
  final String lga;
  final String address;
  final double lat;
  final double lng;

  const LocationEntity({
    required this.state,
    required this.lga,
    required this.address,
    this.lat = 6.5244,
    this.lng = 3.3792,
  });
}

class CarDetailsEntity {
  final String model;
  final String product;
  final int year;
  final String color;
  final String plateNumber;

  const CarDetailsEntity({
    required this.model,
    required this.product,
    required this.year,
    required this.color,
    required this.plateNumber,
  });
}

class ProfileEntity {
  final String userId;
  final String userEmail;
  final bool isDriver;
  final String gender;
  final String role;
  final LocationEntity location;
  final String phoneNumber;
  final String? profilePicture;
  final String? carPicture;
  final String? driverLicense;
  final CarDetailsEntity? carDetails;
  final String? maritalStatus;
  final String? yoe;
  final String? currentLocation;
  final String? languageSpoken;
  final String? gearType;
  final String? vehicleType;
  final List<String> driverRoles;
  final bool interstate;
  final String? question;
  final double ratings;
  final bool verified;

  const ProfileEntity({
    required this.userId,
    required this.userEmail,
    required this.isDriver,
    required this.gender,
    required this.role,
    required this.location,
    required this.phoneNumber,
    this.profilePicture,
    this.carPicture,
    this.driverLicense,
    this.carDetails,
    this.maritalStatus,
    this.yoe,
    this.currentLocation,
    this.languageSpoken,
    this.gearType,
    this.vehicleType,
    this.driverRoles = const [],
    this.interstate = false,
    this.question,
    this.ratings = 0,
    this.verified = false,
  });
}
