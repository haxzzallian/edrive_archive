// lib/features/dashboard/data/datasources/dashboard_remote_datasource.dart

import '../../../../core/network/dio_client.dart';
import '../models/dashboard_model.dart';

abstract class DashboardRemoteDataSource {
  Future<Map<String, dynamic>> getStats();
  Future<Map<String, dynamic>> getProfile();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final DioClient _client;
  DashboardRemoteDataSourceImpl(this._client);

  @override
  Future<Map<String, dynamic>> getStats() async {
    final response = await _client.dio.get('/rides/statistics/my-rides');
    final data = response.data as Map<String, dynamic>;
    return data['stats'] as Map<String, dynamic>? ?? {};
  }

  @override
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _client.dio.get('/auth/dashboard');
    final data = response.data as Map<String, dynamic>;
    return data['profile'] as Map<String, dynamic>? ?? {};
  }
}
