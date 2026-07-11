// import '../../../../core/network/dio_client.dart';
// import '../../../../core/network/endpoints.dart';

// abstract class DriverRemoteDataSource {
//   Future<void> goOnline({required double lat, required double lng});
//   Future<void> goOffline();
//   Future<void> acceptRide(String rideId);
//   Future<void> declineRide(String rideId);
//   Future<Map<String, dynamic>> getEarnings();
//   Future<Map<String, dynamic>> getDriverProfile();
// }

// class DriverRemoteDataSourceImpl implements DriverRemoteDataSource {
//   final DioClient _c;
//   DriverRemoteDataSourceImpl(this._c);
//   @override Future<void> goOnline({required double lat, required double lng}) async =>
//     await _c.dio.post(Endpoints.driverOnline, data: {'lat': lat, 'lng': lng});
//   @override Future<void> goOffline() async => await _c.dio.post(Endpoints.driverOffline);
//   @override Future<void> acceptRide(String rideId) async =>
//     await _c.dio.post(Endpoints.acceptRide, data: {'ride_id': rideId});
//   @override Future<void> declineRide(String rideId) async =>
//     await _c.dio.post(Endpoints.declineRide, data: {'ride_id': rideId});
//   @override Future<Map<String, dynamic>> getEarnings() async {
//     final r = await _c.dio.get(Endpoints.driverEarnings);
//     return r.data as Map<String, dynamic>;
//   }
//   @override Future<Map<String, dynamic>> getDriverProfile() async {
//     final r = await _c.dio.get(Endpoints.myVehicle);
//     return r.data as Map<String, dynamic>;
//   }
// }
