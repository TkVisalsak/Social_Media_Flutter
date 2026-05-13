import 'package:dio/dio.dart';

import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/refresh_interceptor.dart';
import '../providers/local_storage.dart';

class DioClient {
  static const baseUrl = 'http://192.168.1.4:5001/api';
  static Dio? _instance;

  DioClient._();

  static Dio get instance => _instance ??= createDio();

  static Dio createDio({String? baseUrl}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? DioClient.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(tokenProvider: () => LocalStorage.token),
      RefreshInterceptor(
        dio,
        refreshTokenReader: () => LocalStorage.refreshToken,
        accessTokenWriter: (token) => LocalStorage.setToken(token),
      ),
      ErrorInterceptor(),
      LoggingInterceptor(),
    ]);

    return dio;
  }
}

