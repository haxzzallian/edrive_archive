// import '../../../../core/network/dio_client.dart';
// import '../../../../core/network/endpoints.dart';

// abstract class PaymentRemoteDataSource {
//   Future<List<dynamic>> getPaymentMethods();
//   Future<void> addPaymentMethod(Map<String, dynamic> data);
//   Future<Map<String, dynamic>> initiatePayment(Map<String, dynamic> data);
//   Future<Map<String, dynamic>> verifyPayment(String reference);
// }

// class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
//   final DioClient _c;
//   PaymentRemoteDataSourceImpl(this._c);
//   @override Future<List<dynamic>> getPaymentMethods() async {
//     final r = await _c.dio.get(Endpoints.paymentMethods);
//     return r.data['data'] ?? r.data;
//   }
//   @override Future<void> addPaymentMethod(Map<String, dynamic> data) async =>
//     await _c.dio.post(Endpoints.addPaymentMethod, data: data);
//   @override Future<Map<String, dynamic>> initiatePayment(Map<String, dynamic> data) async {
//     final r = await _c.dio.post(Endpoints.initiatePayment, data: data);
//     return r.data as Map<String, dynamic>;
//   }
//   @override Future<Map<String, dynamic>> verifyPayment(String reference) async {
//     final r = await _c.dio.post(Endpoints.verifyPayment, data: {'reference': reference});
//     return r.data as Map<String, dynamic>;
//   }
// }
