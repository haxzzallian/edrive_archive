// lib/features/auth/data/datasources/profile_setup_remote_datasource.dart
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/profile_model.dart';

abstract class ProfileSetupRemoteDataSource {
  Future<ProfileModel> createClientProfile(Map<String, dynamic> body);
  Future<ProfileModel> createDriverProfile(Map<String, dynamic> body);
  Future<String> uploadImage(
      {required String filePath, required String folder});
}

class ProfileSetupRemoteDataSourceImpl implements ProfileSetupRemoteDataSource {
  final DioClient _client;
  ProfileSetupRemoteDataSourceImpl(this._client);

  @override
  Future<ProfileModel> createClientProfile(Map<String, dynamic> body) async {
    final response =
        await _client.dio.post(Endpoints.createProfile, data: body);
    final data = response.data as Map<String, dynamic>;
    return ProfileModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  @override
  Future<ProfileModel> createDriverProfile(Map<String, dynamic> body) async {
    final response =
        await _client.dio.post(Endpoints.createProfile, data: body);
    final data = response.data as Map<String, dynamic>;
    return ProfileModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  // POST https://api.cloudinary.com/v1_1/digzrkdoe/image/upload
  // upload_preset: oosh_preset  (unsigned preset from the website inspection)
  @override
  Future<String> uploadImage({
    required String filePath,
    required String folder,
  }) async {
    final file = File(filePath);

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
      'upload_preset': 'oosh_preset', // ← correct preset from website
    });

    // Cloudinary has its own Dio — no auth header, no base URL from DioClient
    final cloudinaryDio = Dio();
    final response = await cloudinaryDio.post(
      Endpoints.cloudinaryUrl,
      data: formData,
    );

    final secureUrl = response.data['secure_url'] as String?;
    if (secureUrl == null || secureUrl.isEmpty) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Cloudinary upload returned no secure_url',
      );
    }
    return secureUrl;
  }
}
