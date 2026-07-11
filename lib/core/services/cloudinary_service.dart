// lib/core/services/cloudinary_service.dart
import 'dart:io';
import 'package:dio/dio.dart';

class CloudinaryService {
  CloudinaryService._();
  static final CloudinaryService instance = CloudinaryService._();

  static const String _cloudName = 'digzrkdoe';
  static const String _uploadUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';
  static const String _uploadPreset =
      'ml_default'; // replace with your unsigned preset

  final _dio = Dio();

  /// Uploads [file] to Cloudinary, returns the secure_url on success.
  /// Throws on failure.
  Future<String> uploadImage(File file, {String folder = 'edrive'}) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path,
          filename: file.path.split('/').last),
      'upload_preset': _uploadPreset,
      'folder': folder,
    });

    final response = await _dio.post(_uploadUrl, data: formData);
    final data = response.data as Map<String, dynamic>;
    final url = data['secure_url'] as String?;
    if (url == null || url.isEmpty)
      throw Exception('Cloudinary upload failed: no url returned');
    return url;
  }
}
