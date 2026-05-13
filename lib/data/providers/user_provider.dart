import 'package:dio/dio.dart';

import '../network/api_endpoint.dart';

class UserProvider {
  const UserProvider(this._dio);
  final Dio _dio;

  Future<Response<dynamic>> getById(String userId) =>
      _dio.get('${ApiEndpoints.userById}/$userId');

  Future<Response<dynamic>> me() => _dio.get(ApiEndpoints.me);

  Future<Response<dynamic>> updatePersonalInfo({
    String? firstName,
    String? lastName,
    String? dob,
    String? gender,
    String? bio,
  }) =>
      _dio.post(ApiEndpoints.personalInfo, data: {
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (dob != null) 'dob': dob,
        if (gender != null) 'gender': gender,
        if (bio != null) 'bio': bio,
      });

  Future<Response<dynamic>> updateProfilePic(String profilePicUrl) =>
      _dio.put(ApiEndpoints.updateProfile, data: {'profilePic': profilePicUrl});

  Future<Response<dynamic>> getEmail() => _dio.get('/auth/getUserEmail');

  Future<Response<dynamic>> searchUsers(String q, {int limit = 20}) =>
      _dio.get(ApiEndpoints.search, queryParameters: {'q': q, 'limit': limit});
}
