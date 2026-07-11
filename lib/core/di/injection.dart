// lib/core/di/injection.dart
// Add these to configureDependencies() after the profile setup block

// ── Ride ─────────────────────────────────────────────────────────────────────

// Add these imports at the top of injection.dart:
// import '../../features/ride/data/datasources/ride_remote_datasource.dart';
// import '../../features/ride/data/repositories/ride_repository_impl.dart';
// import '../../features/ride/domain/repositories/ride_repository.dart';
// import '../../features/ride/domain/usecases/ride_usecases.dart';

// Add inside configureDependencies():
// getIt.registerLazySingleton<RideRemoteDataSource>(
//     () => RideRemoteDataSourceImpl(getIt<DioClient>()));
// getIt.registerLazySingleton<RideRepository>(
//     () => RideRepositoryImpl(getIt<RideRemoteDataSource>()));
// getIt.registerLazySingleton(() => CreateRideUseCase(getIt<RideRepository>()));
// getIt.registerLazySingleton(() => GetClientRidesUseCase(getIt<RideRepository>()));
// getIt.registerLazySingleton(() => GetRideChatUseCase(getIt<RideRepository>()));
// getIt.registerLazySingleton(() => CancelRideUseCase(getIt<RideRepository>()));

// ─────────────────────────────────────────────────────────────────────────────
// Full updated injection.dart:
// ─────────────────────────────────────────────────────────────────────────────

import 'package:e_drive/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:e_drive/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:e_drive/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:e_drive/features/dashboard/domain/usecases/get_dashboard_usecase.dart';
import 'package:get_it/get_it.dart';
import '../network/dio_client.dart';
import '../services/token_storage.dart';

// Auth
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../../features/auth/domain/usecases/resend_otp_usecase.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';

// Profile Setup
import '../../features/auth/data/datasources/profile_setup_remote_datasource.dart';
import '../../features/auth/data/repositories/profile_setup_repository_impl.dart';
import '../../features/auth/domain/repositories/profile_setup_repository.dart';
import '../../features/auth/domain/usecases/create_client_profile_usecase.dart';
import '../../features/auth/domain/usecases/create_driver_profile_usecase.dart';
import '../../features/auth/domain/usecases/upload_image_usecase.dart';

// Ride
import '../../features/ride/data/datasources/ride_remote_datasource.dart';
import '../../features/ride/data/repositories/ride_repository_impl.dart';
import '../../features/ride/domain/repositories/ride_repository.dart';
import '../../features/ride/domain/usecases/ride_usecases.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // ── Core ────────────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<DioClient>(() => DioClient());
  await TokenStorage.instance.init();

  // ── Auth ────────────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(getIt<DioClient>()));
  getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()));
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => VerifyOtpUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => ResendOtpUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
      () => ForgotPasswordUseCase(getIt<AuthRepository>()));

  // ── Profile Setup ────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<ProfileSetupRemoteDataSource>(
      () => ProfileSetupRemoteDataSourceImpl(getIt<DioClient>()));
  getIt.registerLazySingleton<ProfileSetupRepository>(
      () => ProfileSetupRepositoryImpl(getIt<ProfileSetupRemoteDataSource>()));
  getIt.registerLazySingleton(
      () => CreateClientProfileUseCase(getIt<ProfileSetupRepository>()));
  getIt.registerLazySingleton(
      () => CreateDriverProfileUseCase(getIt<ProfileSetupRepository>()));
  getIt.registerLazySingleton(
      () => UploadImageUseCase(getIt<ProfileSetupRepository>()));

  // ── Ride ─────────────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<RideRemoteDataSource>(
      () => RideRemoteDataSourceImpl(getIt<DioClient>()));
  getIt.registerLazySingleton<RideRepository>(
      () => RideRepositoryImpl(getIt<RideRemoteDataSource>()));
  getIt.registerLazySingleton(() => CreateRideUseCase(getIt<RideRepository>()));
  getIt.registerLazySingleton(
      () => GetClientRidesUseCase(getIt<RideRepository>()));
  getIt
      .registerLazySingleton(() => GetRideChatUseCase(getIt<RideRepository>()));
  getIt.registerLazySingleton(() => CancelRideUseCase(getIt<RideRepository>()));

//dashboard
  getIt.registerLazySingleton<DashboardRemoteDataSource>(
      () => DashboardRemoteDataSourceImpl(getIt<DioClient>()));
  getIt.registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(getIt<DashboardRemoteDataSource>()));
  getIt.registerLazySingleton(
      () => GetDashboardUseCase(getIt<DashboardRepository>()));
}

// // lib/core/di/injection.dart

// import 'package:get_it/get_it.dart';
// import '../network/dio_client.dart';
// import '../services/token_storage.dart';

// // Auth
// import '../../features/auth/data/datasources/auth_remote_datasource.dart';
// import '../../features/auth/data/repositories/auth_repository_impl.dart';
// import '../../features/auth/domain/repositories/auth_repository.dart';
// import '../../features/auth/domain/usecases/login_usecase.dart';
// import '../../features/auth/domain/usecases/register_usecase.dart';
// import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
// import '../../features/auth/domain/usecases/resend_otp_usecase.dart';
// import '../../features/auth/domain/usecases/forgot_password_usecase.dart';

// // Profile Setup
// import '../../features/auth/data/datasources/profile_setup_remote_datasource.dart';
// import '../../features/auth/data/repositories/profile_setup_repository_impl.dart';
// import '../../features/auth/domain/repositories/profile_setup_repository.dart';
// import '../../features/auth/domain/usecases/create_client_profile_usecase.dart';
// import '../../features/auth/domain/usecases/create_driver_profile_usecase.dart';
// import '../../features/auth/domain/usecases/upload_image_usecase.dart';

// final getIt = GetIt.instance;

// Future<void> configureDependencies() async {
//   // ── Core ────────────────────────────────────────────────────────────────────
//   getIt.registerLazySingleton<DioClient>(() => DioClient());
//   await TokenStorage.instance.init();

//   // ── Auth datasource → repository → use cases ────────────────────────────────
//   getIt.registerLazySingleton<AuthRemoteDataSource>(
//       () => AuthRemoteDataSourceImpl(getIt<DioClient>()));

//   getIt.registerLazySingleton<AuthRepository>(
//       () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()));

//   getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
//   getIt.registerLazySingleton(() => RegisterUseCase(getIt<AuthRepository>()));
//   getIt.registerLazySingleton(() => VerifyOtpUseCase(getIt<AuthRepository>()));
//   getIt.registerLazySingleton(() => ResendOtpUseCase(getIt<AuthRepository>()));
//   getIt.registerLazySingleton(
//       () => ForgotPasswordUseCase(getIt<AuthRepository>()));

//   // ── Profile Setup datasource → repository → use cases ───────────────────────
//   getIt.registerLazySingleton<ProfileSetupRemoteDataSource>(
//       () => ProfileSetupRemoteDataSourceImpl(getIt<DioClient>()));

//   getIt.registerLazySingleton<ProfileSetupRepository>(
//       () => ProfileSetupRepositoryImpl(getIt<ProfileSetupRemoteDataSource>()));

//   getIt.registerLazySingleton(
//       () => CreateClientProfileUseCase(getIt<ProfileSetupRepository>()));
//   getIt.registerLazySingleton(
//       () => CreateDriverProfileUseCase(getIt<ProfileSetupRepository>()));
//   getIt.registerLazySingleton(
//       () => UploadImageUseCase(getIt<ProfileSetupRepository>()));
// }
