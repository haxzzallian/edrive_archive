// lib/features/auth/data/datasources/auth_remote_datasource.dart

import '../../../../core/network/dio_client.dart';
import '../models/auth_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> login({required String email, required String password});

  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
  });

  Future<void> verifyEmail({required String email, required String code});

  Future<void> resendOtp({required String email});

  Future<void> forgotPassword({required String email});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _client;
  AuthRemoteDataSourceImpl(this._client);

  // POST /auth/login
  // Body: { email, password }
  @override
  Future<AuthModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return AuthModel.fromLoginJson(response.data as Map<String, dynamic>);
  }

  // POST /auth/register
  // Body: { firstName, lastName, email, password, role }
  @override
  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await _client.dio.post(
      '/auth/register',
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'role': role,
      },
    );
    final data = response.data as Map<String, dynamic>;
    final userJson = data['user'] as Map<String, dynamic>;
    return UserModel.fromJson(userJson);
  }

  // POST /auth/verify-email
  // Body: { email, code }  ← field is "code" not "otp"
  @override
  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    await _client.dio.post(
      '/auth/verify-email',
      data: {'email': email, 'code': code},
    );
  }

  // POST /auth/send-otp
  // Body: { email }
  @override
  Future<void> resendOtp({required String email}) async {
    await _client.dio.post(
      '/auth/send-otp',
      data: {'email': email},
    );
  }

  // POST /auth/forgot-password
  // Body: { email }
  @override
  Future<void> forgotPassword({required String email}) async {
    await _client.dio.post(
      '/auth/forgot-password',
      data: {'email': email},
    );
  }
}
