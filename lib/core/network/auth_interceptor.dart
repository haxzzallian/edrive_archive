// lib/core/network/auth_interceptor.dart
import 'package:dio/dio.dart';
import '../services/token_storage.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = TokenStorage.instance.token;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Clear everything — session + pending verification
      TokenStorage.instance.clearSession();
      // Navigation to login is handled by GoRouter's redirect:
      // AuthGuard.redirect() checks hasToken and redirects when it's gone.
      // The ProviderScope will rebuild and the router will pick it up.
    }
    super.onError(err, handler);
  }
}
