// import '../../../../core/network/dio_client.dart';
// import '../../../../core/network/endpoints.dart';

// abstract class ProfileRemoteDataSource {
//   Future<Map<String, dynamic>> getProfile();
//   Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data);
//   Future<String> uploadAvatar(String filePath);
// }

// class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
//   final DioClient _c;
//   ProfileRemoteDataSourceImpl(this._c);
//   @override Future<Map<String, dynamic>> getProfile() async {
//     final r = await _c.dio.get(Endpoints.profile);
//     return r.data as Map<String, dynamic>;
//   }
//   @override Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
//     final r = await _c.dio.post(Endpoints.updateProfile, data: data);
//     return r.data as Map<String, dynamic>;
//   }
//   @override Future<String> uploadAvatar(String filePath) async {
//     final r = await _c.dio.post(Endpoints.uploadAvatar);
//     return r.data['url'] ?? '';
//   }
// }
