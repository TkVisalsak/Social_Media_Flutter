import 'package:dio/dio.dart';
import '../exceptions/app_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appErr = switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout => NetworkException('Request timed out'),
      DioExceptionType.connectionError => NetworkException('No internet connection'),
      DioExceptionType.badResponse => _fromStatus(err.response?.statusCode ?? 500),
      _ => AppException('Unexpected error'),
    };
    handler.reject(DioException(
      requestOptions: err.requestOptions,
      error: appErr,
    ));
  }

  AppException _fromStatus(int code) => switch (code) {
    400 => ServerException('Bad request'),
    403 => ServerException('Forbidden'),
    404 => ServerException('Not found'),
    422 => ServerException('Validation error'),
    500 => ServerException('Server error'),
    _   => ServerException('HTTP $code'),
  };
}