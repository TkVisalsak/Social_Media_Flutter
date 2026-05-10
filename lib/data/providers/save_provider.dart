import 'package:dio/dio.dart';

import '../network/api_endpoint.dart';

class SaveProvider {
  const SaveProvider(this._dio);
  final Dio _dio;

  Future<Response<dynamic>> save({
    required String contentId,
    required String contentType, // 'feed' | 'short'
  }) =>
      _dio.post(ApiEndpoints.save, data: {
        'contentId': contentId,
        'contentType': contentType,
      });

  Future<Response<dynamic>> unsave(String contentId) =>
      _dio.delete('${ApiEndpoints.save}/$contentId');

  Future<Response<dynamic>> isSaved(String contentId) =>
      _dio.get('${ApiEndpoints.saveCheck}/$contentId');

  Future<Response<dynamic>> savedByUser(String userId) =>
      _dio.get('${ApiEndpoints.save}/$userId');
}
