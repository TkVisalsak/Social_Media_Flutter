import 'package:dio/dio.dart';
import '../exceptions/app_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appErr = switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout => NetworkException('Request timed out'),
      DioExceptionType.connectionError => NetworkException('No internet connection'),
      DioExceptionType.badResponse => _fromResponse(err.response),
      _ => AppException('Unexpected error'),
    };
    handler.reject(DioException(
      requestOptions: err.requestOptions,
      error: appErr,
    ));
  }

  AppException _fromResponse(Response<dynamic>? response) {
    final code = response?.statusCode ?? 500;
    final data = response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'] ?? data['detail'];
      if (message is String && message.trim().isNotEmpty) {
        return ServerException(message);
      }

      final errors = data['errors'];
      if (errors is Map<String, dynamic> && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty && first.first is String) {
          return ServerException(first.first as String);
        }
        if (first is String && first.trim().isNotEmpty) {
          return ServerException(first);
        }
      }
    }

    return switch (code) {
      400 => ServerException('Bad request'),
      401 => ServerException('Unauthorized'),
      403 => ServerException('Forbidden'),
      404 => ServerException('Not found'),
      422 => ServerException('Validation error'),
      500 => ServerException('Server error'),
      _   => ServerException('HTTP $code'),
    };
  }
}