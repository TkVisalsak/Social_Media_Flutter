import 'package:dio/dio.dart';

import '../network/api_endpoint.dart';

class HobbyProvider {
  const HobbyProvider(this._dio);
  final Dio _dio;

  Future<Response<dynamic>> getAll() => _dio.get(ApiEndpoints.hobbies);

  Future<Response<dynamic>> getMine() => _dio.get(ApiEndpoints.myHobbies);

  Future<Response<dynamic>> setMine(List<String> hobbies) =>
      _dio.post(ApiEndpoints.myHobbies, data: {'hobbies': hobbies});

  Future<Response<dynamic>> suggestions({int min = 3, int limit = 20}) =>
      _dio.get(
        ApiEndpoints.hobbySuggestions,
        queryParameters: {'min': min, 'limit': limit},
      );
}
