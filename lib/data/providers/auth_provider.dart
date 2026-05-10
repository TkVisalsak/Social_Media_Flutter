import 'package:dio/dio.dart';

import '../network/api_endpoint.dart';

class AuthProvider {
  AuthProvider(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> login({
    required String email,
    required String password,
  }) {
    return _dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
  }

  Future<Response<dynamic>> register({
    required String email,
    required String password,
    required String username,
  }) {
    return _dio.post(
      ApiEndpoints.register,
      data: {
        'email': email,
        'password': password,
        'userName': username,
      },
    );
  }

  Future<Response<dynamic>> logout() {
    return _dio.post(ApiEndpoints.logout);
  }

  Future<Response<dynamic>> forgotPassword({required String email}) {
    return _dio.post(
      '/auth/forgot-password',
      data: {'email': email},
    );
  }

  Future<Response<dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) {
    return _dio.post(
      '/auth/reset-password',
      data: {
        'token': token,
        'new_password': newPassword,
      },
    );
  }

  Future<Response<dynamic>> me() {
    return _dio.get('/auth/me');
  }

  Future<Response<dynamic>> personalInfo(Map<String, dynamic> data) {
    return _dio.post(ApiEndpoints.personalInfo, data: data);
  }

  Future<Response<dynamic>> updateProfilePic(FormData formData) {
    return _dio.put(ApiEndpoints.updateProfile, data: formData);
  }
}
