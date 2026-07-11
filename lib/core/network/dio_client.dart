// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/flavor_config.dart';
import 'auth_interceptor.dart';

class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(BaseOptions(
      // Uses FlavorConfig so each flavor points to correct environment
      baseUrl: FlavorConfig.instance.baseUrl, // e.g. https://api.edrive.ng/api
      connectTimeout: const Duration(seconds: 100),
      receiveTimeout: const Duration(seconds: 100),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
    ));
    dio.interceptors.add(AuthInterceptor());
    if (FlavorConfig.instance.enableLogging) {
      dio.interceptors.add(PrettyDioLogger(
          requestHeader: false, requestBody: true, responseBody: true));
    }
  }
}
