// lib/features/auth/presentation/providers/profile_setup_notifier.dart

import 'package:e_drive/core/di/injection.dart';
import 'package:e_drive/features/auth/domain/entities/create_profile_params.dart';
import 'package:e_drive/features/auth/domain/entities/hired_details_entity.dart';
import 'package:e_drive/features/auth/domain/entities/profile_entity.dart';
import 'package:e_drive/features/auth/domain/usecases/create_client_profile_usecase.dart';
import 'package:e_drive/features/auth/domain/usecases/create_driver_profile_usecase.dart';
import 'package:e_drive/features/auth/domain/usecases/upload_image_usecase.dart';
import 'package:e_drive/features/auth/presentation/providers/profile_setup_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileSetupNotifier extends StateNotifier<ProfileSetupState> {
  final CreateClientProfileUseCase _createClient;
  final CreateDriverProfileUseCase _createDriver;
  final UploadImageUseCase _uploadImage;

  ProfileSetupNotifier(
      this._createClient, this._createDriver, this._uploadImage)
      : super(const ProfileSetupState());

  void nextStep() => state = state.copyWith(step: state.step + 1);
  void prevStep() => state = state.copyWith(step: state.step - 1);
  void clearError() => state = state.copyWith(clearError: true);

  // ── Uploads ──────────────────────────────────────────────────────────────
  Future<bool> uploadProfilePicture(String filePath) async {
    state = state.copyWith(isUploadingProfile: true, clearError: true);
    final result = await _uploadImage(
        UploadImageParams(filePath: filePath, folder: 'edrive/profiles'));
    return result.fold(
      (f) {
        state = state.copyWith(isUploadingProfile: false, error: f.message);
        return false;
      },
      (url) {
        state =
            state.copyWith(isUploadingProfile: false, profilePictureUrl: url);
        return true;
      },
    );
  }

  Future<bool> uploadCarPicture(String filePath) async {
    state = state.copyWith(isUploadingCar: true, clearError: true);
    final result = await _uploadImage(
        UploadImageParams(filePath: filePath, folder: 'edrive/cars'));
    return result.fold(
      (f) {
        state = state.copyWith(isUploadingCar: false, error: f.message);
        return false;
      },
      (url) {
        state = state.copyWith(isUploadingCar: false, carPictureUrl: url);
        return true;
      },
    );
  }

  Future<bool> uploadDriverLicense(String filePath) async {
    state = state.copyWith(isUploadingLicense: true, clearError: true);
    final result = await _uploadImage(
        UploadImageParams(filePath: filePath, folder: 'edrive/licenses'));
    return result.fold(
      (f) {
        state = state.copyWith(isUploadingLicense: false, error: f.message);
        return false;
      },
      (url) {
        state =
            state.copyWith(isUploadingLicense: false, driverLicenseUrl: url);
        return true;
      },
    );
  }

  // ── Setters ───────────────────────────────────────────────────────────────
  void setQuestion(String v) => state = state.copyWith(question: v);
  void setGender(String v) => state = state.copyWith(gender: v);
  void setPhone(String v) => state = state.copyWith(phone: v);
  void setAddress(String v) => state = state.copyWith(address: v);
  void setState_(String v) => state = state.copyWith(state: v, lga: '');
  void setLga(String v) => state = state.copyWith(lga: v);
  void setInterstate(bool v) => state = state.copyWith(interstate: v);
  void setGearType(String v) => state = state.copyWith(gearType: v);
  void setMaritalStatus(String v) => state = state.copyWith(maritalStatus: v);
  void setVehicleType(String v) => state = state.copyWith(vehicleType: v);
  void setCurrentLocation(String v) =>
      state = state.copyWith(currentLocation: v);
  void setYoe(String v) => state = state.copyWith(yoe: v);
  void setLanguage(String v) => state = state.copyWith(languageSpoken: v);
  void setCarModel(String v) => state = state.copyWith(carModel: v);
  void setCarProduct(String v) => state = state.copyWith(carProduct: v);
  void setCarYear(String v) => state = state.copyWith(carYear: v);
  void setCarColor(String v) => state = state.copyWith(carColor: v);
  void setPlateNumber(String v) => state = state.copyWith(plateNumber: v);
  void setCoordinates(double lat, double lng) =>
      state = state.copyWith(lat: lat, lng: lng);

  // ── Hired details setters ─────────────────────────────────────────────────
  void setHiredDurationType(String v) =>
      state = state.copyWith(hiredDurationType: v);
  void setHiredMinSalary(String v) => state = state.copyWith(hiredMinSalary: v);
  void setHiredInterstate(bool v) => state = state.copyWith(hiredInterstate: v);
  void setHiredTypeOfCar(String v) => state = state.copyWith(hiredTypeOfCar: v);
  void setHiredTransmission(String v) =>
      state = state.copyWith(hiredTransmission: v);
  void setHiredPreference(String v) =>
      state = state.copyWith(hiredPreference: v);

  void toggleDriverRole(String role) {
    final roles = List<String>.from(state.driverRoles);
    roles.contains(role) ? roles.remove(role) : roles.add(role);
    state = state.copyWith(driverRoles: roles);
  }

  // ── Submit client ─────────────────────────────────────────────────────────
  Future<bool> submitClientProfile(String userEmail) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    final params = CreateClientProfileParams(
      userEmail: userEmail,
      question: state.question,
      gender: state.gender,
      phoneNumber: state.phone,
      profilePictureUrl: state.profilePictureUrl,
      location: LocationEntity(
        state: state.state,
        lga: state.lga,
        address: state.address,
        lat: state.lat,
        lng: state.lng,
      ),
    );
    final result = await _createClient(params);
    return result.fold(
      (f) {
        state = state.copyWith(isSubmitting: false, error: f.message);
        return false;
      },
      (profile) {
        state = state.copyWith(
            isSubmitting: false, createdProfile: ProfileWrap(profile));
        return true;
      },
    );
  }

  // ── Submit driver ─────────────────────────────────────────────────────────
  Future<bool> submitDriverProfile(String userEmail) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    // Build hired details only if 'hired' role is selected
    final hiredDetails = state.hasHiredRole
        ? HiredDetailsEntity(
            durationType: state.hiredDurationType,
            minimumSalary: state.hiredMinSalary,
            interstateTravel: state.hiredInterstate,
            typeOfCar: state.hiredTypeOfCar,
            transmission: state.hiredTransmission,
            preference: state.hiredPreference,
          )
        : null;

    final params = CreateDriverProfileParams(
      userEmail: userEmail,
      gender: state.gender,
      phoneNumber: state.phone,
      profilePictureUrl: state.profilePictureUrl,
      carPictureUrl: state.carPictureUrl,
      driverLicenseUrl: state.driverLicenseUrl,
      maritalStatus: state.maritalStatus,
      yoe: state.yoe,
      currentLocation: state.currentLocation,
      languageSpoken: state.languageSpoken,
      gearType: state.gearType,
      vehicleType: state.vehicleType,
      driverRoles: state.driverRoles,
      interstate: state.interstate,
      hiredDetails: hiredDetails,
      location: LocationEntity(
        state: state.state,
        lga: state.lga,
        address: state.address,
        lat: state.lat,
        lng: state.lng,
      ),
      carDetails: CarDetailsEntity(
        model: state.carModel,
        product: state.carProduct,
        year: int.tryParse(state.carYear) ?? 0,
        color: state.carColor,
        plateNumber: state.plateNumber,
      ),
    );

    final result = await _createDriver(params);
    return result.fold(
      (f) {
        state = state.copyWith(isSubmitting: false, error: f.message);
        return false;
      },
      (profile) {
        state = state.copyWith(
            isSubmitting: false, createdProfile: ProfileWrap(profile));
        return true;
      },
    );
  }
}

final profileSetupProvider =
    StateNotifierProvider.autoDispose<ProfileSetupNotifier, ProfileSetupState>(
  (ref) => ProfileSetupNotifier(
    getIt<CreateClientProfileUseCase>(),
    getIt<CreateDriverProfileUseCase>(),
    getIt<UploadImageUseCase>(),
  ),
);
