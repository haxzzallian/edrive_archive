import 'package:dio/dio.dart';
import 'failures.dart';

Failure handleDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return const NetworkFailure('Connection timed out');
    case DioExceptionType.badResponse:
      final code = e.response?.statusCode;
      if (code == 401) return const UnauthorizedFailure();
      if (code == 404) return const NotFoundFailure();
      if (code == 422) return ValidationFailure(
        e.response?.data?['message'] ?? 'Validation error',
      );
      return ServerFailure(e.response?.data?['message'] ?? 'Server error');
    case DioExceptionType.connectionError:
      return const NetworkFailure();
    default:
      return UnknownFailure(e.message ?? 'Unknown error');
  }
}
