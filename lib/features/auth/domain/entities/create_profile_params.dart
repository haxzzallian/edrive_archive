// lib/features/auth/domain/entities/create_profile_params.dart

import 'profile_entity.dart';
import 'hired_details_entity.dart';

class CreateClientProfileParams {
  final String userEmail;
  final String question;
  final String gender;
  final LocationEntity location;
  final String phoneNumber;
  final String? profilePictureUrl;

  const CreateClientProfileParams({
    required this.userEmail,
    required this.question,
    required this.gender,
    required this.location,
    required this.phoneNumber,
    this.profilePictureUrl,
  });
}

class CreateDriverProfileParams {
  final String userEmail;
  final String gender;
  final LocationEntity location;
  final String phoneNumber;
  final String? profilePictureUrl;
  final String? carPictureUrl;
  final String? driverLicenseUrl;
  final CarDetailsEntity carDetails;
  final String maritalStatus;
  final String yoe;
  final String currentLocation;
  final String languageSpoken;
  final String gearType;
  final String vehicleType;
  final List<String> driverRoles;
  final bool interstate;
  // Only present when 'hired' is in driverRoles
  final HiredDetailsEntity? hiredDetails;

  const CreateDriverProfileParams({
    required this.userEmail,
    required this.gender,
    required this.location,
    required this.phoneNumber,
    required this.carDetails,
    required this.maritalStatus,
    required this.yoe,
    required this.currentLocation,
    required this.languageSpoken,
    required this.gearType,
    required this.vehicleType,
    required this.driverRoles,
    required this.interstate,
    this.profilePictureUrl,
    this.carPictureUrl,
    this.driverLicenseUrl,
    this.hiredDetails,
  });
}

class UploadImageParams {
  final String filePath;
  final String folder;
  const UploadImageParams({required this.filePath, this.folder = 'edrive'});
}
