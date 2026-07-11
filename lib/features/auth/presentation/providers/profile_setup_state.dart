// lib/features/auth/presentation/providers/profile_setup_state.dart

import 'package:e_drive/features/auth/domain/entities/profile_entity.dart';

class ProfileWrap<T> {
  final T value;
  const ProfileWrap(this.value);
}

class ProfileSetupState {
  final int step;
  final bool isSubmitting;
  final bool isUploadingProfile;
  final bool isUploadingCar;
  final bool isUploadingLicense;
  final String? error;
  final ProfileEntity? createdProfile;

  final String question;
  final String gender;
  final String phone;
  final String address;
  final String state;
  final String lga;
  final double lat;
  final double lng;
  final String? profilePictureUrl;
  final String? carPictureUrl;
  final String? driverLicenseUrl;
  final List<String> driverRoles;
  final bool interstate;
  final String gearType;
  final String maritalStatus;
  final String vehicleType;
  final String currentLocation;
  final String yoe;
  final String languageSpoken;
  final String carModel;
  final String carProduct;
  final String carYear;
  final String carColor;
  final String plateNumber;

  // ── Hired driver details (only required when 'hired' is in driverRoles) ───
  final String hiredDurationType;
  final String hiredMinSalary;
  final bool hiredInterstate;
  final String hiredTypeOfCar;
  final String hiredTransmission;
  final String hiredPreference;

  const ProfileSetupState({
    this.step = 1,
    this.isSubmitting = false,
    this.isUploadingProfile = false,
    this.isUploadingCar = false,
    this.isUploadingLicense = false,
    this.error,
    this.createdProfile,
    this.question = '',
    this.gender = '',
    this.phone = '',
    this.address = '',
    this.state = '',
    this.lga = '',
    this.lat = 0.0,
    this.lng = 0.0,
    this.profilePictureUrl,
    this.carPictureUrl,
    this.driverLicenseUrl,
    this.driverRoles = const ['ride-hauling'],
    this.interstate = false,
    this.gearType = '',
    this.maritalStatus = '',
    this.vehicleType = '',
    this.currentLocation = '',
    this.yoe = '',
    this.languageSpoken = '',
    this.carModel = '',
    this.carProduct = '',
    this.carYear = '',
    this.carColor = '',
    this.plateNumber = '',
    this.hiredDurationType = '',
    this.hiredMinSalary = '',
    this.hiredInterstate = false,
    this.hiredTypeOfCar = '',
    this.hiredTransmission = '',
    this.hiredPreference = '',
  });

  bool get isUploadingAny =>
      isUploadingProfile || isUploadingCar || isUploadingLicense;

  bool get hasHiredRole => driverRoles.contains('hired');

  ProfileSetupState copyWith({
    int? step,
    bool? isSubmitting,
    bool? isUploadingProfile,
    bool? isUploadingCar,
    bool? isUploadingLicense,
    String? error,
    ProfileWrap<ProfileEntity?>? createdProfile,
    String? question,
    String? gender,
    String? phone,
    String? address,
    String? state,
    String? lga,
    double? lat,
    double? lng,
    String? profilePictureUrl,
    String? carPictureUrl,
    String? driverLicenseUrl,
    List<String>? driverRoles,
    bool? interstate,
    String? gearType,
    String? maritalStatus,
    String? vehicleType,
    String? currentLocation,
    String? yoe,
    String? languageSpoken,
    String? carModel,
    String? carProduct,
    String? carYear,
    String? carColor,
    String? plateNumber,
    String? hiredDurationType,
    String? hiredMinSalary,
    bool? hiredInterstate,
    String? hiredTypeOfCar,
    String? hiredTransmission,
    String? hiredPreference,
    bool clearError = false,
  }) =>
      ProfileSetupState(
        step: step ?? this.step,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        isUploadingProfile: isUploadingProfile ?? this.isUploadingProfile,
        isUploadingCar: isUploadingCar ?? this.isUploadingCar,
        isUploadingLicense: isUploadingLicense ?? this.isUploadingLicense,
        error: clearError ? null : (error ?? this.error),
        createdProfile:
            createdProfile != null ? createdProfile.value : this.createdProfile,
        question: question ?? this.question,
        gender: gender ?? this.gender,
        phone: phone ?? this.phone,
        address: address ?? this.address,
        state: state ?? this.state,
        lga: lga ?? this.lga,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
        carPictureUrl: carPictureUrl ?? this.carPictureUrl,
        driverLicenseUrl: driverLicenseUrl ?? this.driverLicenseUrl,
        driverRoles: driverRoles ?? this.driverRoles,
        interstate: interstate ?? this.interstate,
        gearType: gearType ?? this.gearType,
        maritalStatus: maritalStatus ?? this.maritalStatus,
        vehicleType: vehicleType ?? this.vehicleType,
        currentLocation: currentLocation ?? this.currentLocation,
        yoe: yoe ?? this.yoe,
        languageSpoken: languageSpoken ?? this.languageSpoken,
        carModel: carModel ?? this.carModel,
        carProduct: carProduct ?? this.carProduct,
        carYear: carYear ?? this.carYear,
        carColor: carColor ?? this.carColor,
        plateNumber: plateNumber ?? this.plateNumber,
        hiredDurationType: hiredDurationType ?? this.hiredDurationType,
        hiredMinSalary: hiredMinSalary ?? this.hiredMinSalary,
        hiredInterstate: hiredInterstate ?? this.hiredInterstate,
        hiredTypeOfCar: hiredTypeOfCar ?? this.hiredTypeOfCar,
        hiredTransmission: hiredTransmission ?? this.hiredTransmission,
        hiredPreference: hiredPreference ?? this.hiredPreference,
      );
}
