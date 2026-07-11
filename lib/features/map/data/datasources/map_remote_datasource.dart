// import '../../../../core/network/dio_client.dart';
// import '../../../../core/network/endpoints.dart';

// abstract class MapRemoteDataSource {
//   Future<List<dynamic>> searchPlaces(String query);
//   Future<List<dynamic>> getFareEstimate(Map<String, dynamic> params);
//   Future<List<dynamic>> getNearbyDrivers({required double lat, required double lng});
// }

// class MapRemoteDataSourceImpl implements MapRemoteDataSource {
//   final DioClient _c;
//   MapRemoteDataSourceImpl(this._c);
//   @override Future<List<dynamic>> searchPlaces(String query) async {
//     final r = await _c.dio.get(Endpoints.searchPlaces, queryParameters: {'q': query});
//     return r.data['results'] ?? r.data;
//   }
//   @override Future<List<dynamic>> getFareEstimate(Map<String, dynamic> params) async {
//     final r = await _c.dio.get(Endpoints.fareEstimate, queryParameters: params);
//     return r.data['estimates'] ?? r.data;
//   }
//   @override Future<List<dynamic>> getNearbyDrivers({required double lat, required double lng}) async {
//     final r = await _c.dio.get(Endpoints.nearbyDrivers, queryParameters: {'lat': lat, 'lng': lng});
//     return r.data['drivers'] ?? r.data;
//   }
// }
